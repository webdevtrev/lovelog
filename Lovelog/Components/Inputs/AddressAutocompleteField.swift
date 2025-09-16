//
//  AddressAutocompleteField.swift
//  Lovelog
//
//  Created by Trevor Cash on 9/11/25.
//


import SwiftUI
import MapKit
import Combine

// MARK: - Public API

/// A reusable SwiftUI field that autocompletes places/addresses.
/// - Parameters:
///   - title: Placeholder/title for the text field
///   - query: The bound text the user types
///   - onSelect: Called with a resolved MKMapItem when the user picks a suggestion
///   - regionHint: Optional region to bias suggestions (e.g. around the user)
struct AddressAutocompleteField: View {
    let title: String
    @Binding var query: String
    var regionHint: MKCoordinateRegion?
    var onSelect: (MKMapItem) -> Void

    @State private var showSuggestions = false
    @StateObject private var model = AutocompleteViewModel()

    var body: some View {
        VStack(spacing: 0) {
            TextField(title, text: $query, onEditingChanged: { editing in
                showSuggestions = editing && !model.suggestions.isEmpty
            })
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .padding(12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.secondary.opacity(0.25), lineWidth: 1)
            )
            .onChange(of: query) { newValue in
                model.updateQuery(newValue, region: regionHint)
                showSuggestions = !newValue.isEmpty && !model.suggestions.isEmpty
            }

            if showSuggestions && !model.suggestions.isEmpty {
                SuggestionsList(
                    items: model.suggestions,
                    isLoading: model.isResolving
                ) { suggestion in
                    Task {
                        if let item = try? await model.resolve(completion: suggestion) {
                            query = formatDisplay(for: item)
                            showSuggestions = false
                            onSelect(item)
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.secondary.opacity(0.15), lineWidth: 1)
                )
                .padding(.top, 6)
            }
        }
        .animation(.smooth(duration: 0.18), value: showSuggestions)
    }

    private func formatDisplay(for item: MKMapItem) -> String {
        let name = item.name ?? ""
        let addr = item.placemark.formattedAddress ?? ""
        if addr.isEmpty { return name }
        if name.isEmpty { return addr }
        return "\(name), \(addr)"
    }
}

// MARK: - ViewModel

@MainActor
final class AutocompleteViewModel: NSObject, ObservableObject {
    @Published var suggestions: [MKLocalSearchCompletion] = []
    @Published var isResolving = false

    private let completer = MKLocalSearchCompleter()
    private var cancellables: Set<AnyCancellable> = []
    private let debouncer = TypingDebouncer(delay: 0.2)

    override init() {
        super.init()
        completer.resultTypes = [.address, .pointOfInterest]
        completer.delegate = self
    }

    func updateQuery(_ fragment: String, region: MKCoordinateRegion?) {
        // Debounce so we don’t spam the service
        debouncer.run { [weak self] in
            guard let self else { return }
            if let region {
                completer.region = region
            }
            completer.queryFragment = fragment
        }
    }

    func resolve(completion: MKLocalSearchCompletion) async throws -> MKMapItem {
        isResolving = true
        defer { isResolving = false }

        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)
        let response = try await search.start()
        // Take the best match
        if let first = response.mapItems.first {
            return first
        }
        // Fallback: build a manual MKMapItem if somehow none returned
        throw NSError(domain: "AddressAutocomplete", code: 404, userInfo: [NSLocalizedDescriptionKey: "No match found"])
    }
}

extension AutocompleteViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        suggestions = completer.results
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // On failure, clear suggestions. You could also show a toast.
        suggestions = []
    }
}

// MARK: - UI Pieces

private struct SuggestionsList: View {
    let items: [MKLocalSearchCompletion]
    let isLoading: Bool
    let onTap: (MKLocalSearchCompletion) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(items, id: \.self) { item in
                Button {
                    onTap(item)
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.title)
                            .font(.callout).fontWeight(.semibold)
                            .lineLimit(1)
                        if !item.subtitle.isEmpty {
                            Text(item.subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.plain)

                if item != items.last {
                    Divider().opacity(0.25)
                }
            }

            if isLoading {
                Divider().opacity(0.25)
                HStack(spacing: 8) {
                    ProgressView().controlSize(.small)
                    Text("Fetching details…").font(.caption)
                }
                .padding(10)
            }
        }
    }
}

// MARK: - Small Utilities

/// Simple typed debouncer to throttle query updates.
final class TypingDebouncer {
    private var workItem: DispatchWorkItem?
    private let delay: TimeInterval
    init(delay: TimeInterval) { self.delay = delay }

    func run(_ block: @escaping () -> Void) {
        workItem?.cancel()
        let item = DispatchWorkItem(block: block)
        workItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: item)
    }
}

private extension MKPlacemark {
    /// Nicely formatted single-line address.
    var formattedAddress: String? {
        let parts: [String?] = [
            subThoroughfare, thoroughfare,
            locality,
            administrativeArea,
            postalCode,
            countryCode == "US" ? nil : country // hide country for US for brevity
        ]
        let joined = parts.compactMap { $0 }.joined(separator: ", ")
        return joined.isEmpty ? nil : joined
    }
}

private struct SelectedPlacePreview: View {
    let item: MKMapItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Map(
                initialPosition: .region(
                    MKCoordinateRegion(
                        center: item.placemark.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                )
            ) {
                Marker(item.name ?? "Selected", coordinate: item.placemark.coordinate)
            }
            .frame(height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.secondary.opacity(0.15), lineWidth: 1)
            )

            // Small summary row
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name ?? "Selected place")
                        .font(.subheadline).bold()
                        .lineLimit(1)
                    if let addr = item.placemark.formattedAddress {
                        Text(addr)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
                Spacer()
                // Optional quick actions
                if let url = item.url {
                    Link("Website", destination: url)
                        .font(.caption)
                }
            }
        }
        .padding(12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    @Previewable @State var locationQuery = ""
    @Previewable @State var selectedItem: MKMapItem?

    let regionHint = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
        span: MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4)
    )

    NavigationStack {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Where will you go?")
                    .font(.headline)

                AddressAutocompleteField(
                    title: "Search place or address",
                    query: $locationQuery,
                    regionHint: regionHint
                ) { mapItem in
                    selectedItem = mapItem
                }

                if let item = selectedItem {
                    SelectedPlacePreview(item: item) // your new map preview card
                }

                Spacer(minLength: 200) // gives room to scroll past keyboard
            }
            .padding()
        }
        .scrollDismissesKeyboard(.interactively) // swipe down to dismiss
        .ignoresSafeArea(.keyboard, edges: .bottom) // prevent overlap
    }
}
