import SwiftUI

enum ValidState: Equatable {
    case empty
    case short
    case long
    case checking
    case duplicate
    case unverified
    case valid
}


struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var name = ""
    @State private var handle = ""
    @State private var handleUnique: Bool = false
    @State private var selectedTheme: ThemeColor? = .red
    @EnvironmentObject private var authStore: SupabaseAuthStore

    @State private var nameValidation: ValidState = .empty
    @State private var handleValidation: ValidState = .empty
    func validateName(){
        guard !handle.isEmpty else {
            nameValidation = .empty
            return
        }
        nameValidation = .valid
    }
    func validateHandle() {
        guard !handle.isEmpty else {
            handleValidation = .empty
            return
        }
        guard handle.count > 3 else {
            handleValidation = .short
            return
        }
        guard handle.count < 16 else {
            handleValidation = .long
            return
        }

        handleValidation = .checking

        Task {
            do {
                print(handle)
                let result : [UserRow] = try await supabase
                    .from("users")
                    .select("id,handle")
                    .eq("handle", value: handle)
                    .execute()
                    .value
                if result.count > 0 {
                    handleValidation = .duplicate
                } else {
                    handleValidation = .valid
                }
            } catch {
                // could also add a `.error` case if you want
                handleValidation = .unverified
            }
        }
    }

    func finishOnboarding(){
//        try await supabase
//            .from("users")
//            .update(["theme_color": selectedThemeColor.rawValue])
//            .eq("id", userId)
    }

    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    switch currentPage {
                    case 0:
                        VStack {
                            Text("What's your name?")
                                .font(.headline)
                            TextField("John", text: $name).appTextFieldStyle()
                                .submitLabel(.next)                  // keyboard shows "Next"
                                .onChange(of: name) { _ in
                                    validateName()
                                }
                                .onSubmit {
                                    if !name.isEmpty {
                                        currentPage += 1
                                    }
                                }
                            if(nameValidation == .empty){
                                Text("Please enter your name")
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            
                        }
                    case 1:
                        VStack {
                            Text("What would you like your username to be?")
                                .font(.headline)
                            TextField("john-doe", text: $handle).appTextFieldStyle()
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                                .onChange(of: handle) { newValue in
                                    handle = newValue.lowercased()
                                    validateHandle()
                                }
                                .submitLabel(.next)                  // keyboard shows "Next"
                                    .onSubmit {
                                        if handleValidation == .valid {
                                            currentPage += 1
                                        }
                                    }
//                            handleValidation != .valid

                            // Validation feedback
                            switch handleValidation {
                            case .empty:
                                Text("Please enter a username")
                                    .foregroundColor(.secondary)
                            case .short:
                                Text("Please enter a username at least 4 characters long")
                                    .foregroundColor(.secondary)
                            case .long:
                                Text("Please enter a shorter username")
                                    .foregroundColor(.secondary)
                            case .checking:
                                ProgressView("Checking availability…")
                            case .duplicate:
                                Text("That username is taken")
                                    .foregroundColor(.red)
                            case .valid:
                                Text("✅ Username available")
                                    .foregroundColor(.green)
                            case .unverified:
                                Text("Could not be verified")
                                    .foregroundColor(.red)
                            }
                            
                            Spacer()
                        }
                    case 2:
                        VStack {
                            Text("Pick your favorite color")
                                        .font(.headline)

                                    HStack(spacing: 20) {
                                        ForEach(ThemeColor.allCases, id: \.self) { theme in
                                            let isSelected = selectedTheme == theme
                                            Circle()
                                                .fill(theme.color)
                                                .frame(width: 48, height: 48) // 44pt+ tap target
                                                .overlay(
                                                    Circle()
                                                        .strokeBorder(.primary, lineWidth: isSelected ? 3 : 0)
                                                )
                                                .contentShape(Circle())
                                                .onTapGesture { selectedTheme = theme }
                                                .accessibilityLabel(theme.displayName)
                                                .accessibilityAddTraits(isSelected ? .isSelected : [])
                                        }
                                    }
                            Spacer()
                        }
                    default:
                        EmptyView()
                    }
                }
                .padding()
                .animation(.easeInOut, value: currentPage)
            }
            .navigationTitle("Welcome to Lovelog") // keeps the bar visible
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        currentPage -= 1
                    } label: {
                        Image(systemName: "chevron.left") // HIG-friendly back icon
                            .imageScale(.large)
                    }
                    .accessibilityLabel("Back")
                    .disabled(currentPage == 0) // don't hide; disable instead
                }
                ToolbarItem(placement: .bottomBar) {
                    if currentPage == 2{
                        Button {
                            Task {
                                    do {
                                        test()
                                        try await saveProfileAndFinish(name: name, handle: handle, selectedTheme: selectedTheme)
                                        authStore.auth = .signedIn
                                    } catch {
                                        // show error UI
                                        print("error:", error.localizedDescription)
                                        print("uh oh")
                                    }
                                }
                            } label: {
                                Text("Finish")
                            }.buttonStyle(.glassProminent)
                        .accessibilityLabel("Finish")
                    }
                    else{
                        Button {
                            currentPage += 1
                        } label: {
                            Text("Continue")
                        }.buttonStyle(.glassProminent)
                        .accessibilityLabel("Continue")
                        .disabled((currentPage == 0 && name.isEmpty) || (currentPage == 1 && handleValidation != .valid))
                    }
                }
            }
        }
    }
}

#Preview {
    OnboardingView()
}
