import DesignSystem
import SwiftUI

struct SignInView: View {
    @State private var model: SignInViewModel

    init(model: SignInViewModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        ScreenLayout(
            title: String(localized: "CoupleWidget"),
            subtitle: String(localized: "Stay close to your partner right from the Home Screen")
        ) {
            EmptyView()
        } actions: {
            PrimaryButton(title: String(localized: "Sign In")) {
                model.signIn()
            }
        }
    }
}

#Preview("Light") {
    SignInView(model: SignInViewModel(navigator: .preview))
}

#Preview("Dark") {
    SignInView(model: SignInViewModel(navigator: .preview))
        .preferredColorScheme(.dark)
}
