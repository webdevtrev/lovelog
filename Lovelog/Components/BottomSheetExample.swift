import SwiftUI

struct BottomSheetExpandedExample: View {
    @State private var showingSheet = false
    @State private var selectedDetent: PresentationDetent = .large // initial state

    var body: some View {
        VStack(spacing: 20) {
            Button("Show Fully Expanded Sheet") {
                showingSheet = true
            }
        }
        .sheet(isPresented: $showingSheet) {
            VStack {
                Text("This opens fully expanded!")
                    .font(.title2)
                    .padding()
                Button("Close") {
                    showingSheet = false
                }
                .padding()
            }
            .presentationDetents([.medium, .large], selection: $selectedDetent)
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    BottomSheetExpandedExample()
}
