import SwiftUI

struct OnboardingView: View {
    @State var currentPage = 0
    let totalPages = 3
    func goNext(){
        currentPage += 1;
    }
    var body: some View {
        VStack {
            if currentPage != 0{
                HStack{
                    Button("Back") {
                            currentPage -= 1
                        
                    }
                    Spacer()
                }
                .padding()
            }
            ZStack {
                switch currentPage {
                case 0:
                    Page1View(onNext: goNext)
                case 1:
                    Page2View(onNext: goNext)
                case 2:
                    Page3View()
                default:
                    EmptyView()
                }
            }
            .animation(.easeInOut, value: currentPage) // smooth transition
        }
    }
}



// Blank placeholder pages
struct Page1View: View {
    let onNext: () -> Void
    var body: some View {
        VStack {
            Spacer()
            Text("Page 1")
            Spacer()
            Button(action: onNext) {
                Text("Continue")
            }
        }
    }
}

struct Page2View: View {
    let onNext: () -> Void
    var body: some View {
        VStack {
            Spacer()
            Text("Page 2")
            Spacer()
            Button(action: onNext) {
                Text("Continue")
            }
        }
    }
}

struct Page3View: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Page 3")
            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
}
