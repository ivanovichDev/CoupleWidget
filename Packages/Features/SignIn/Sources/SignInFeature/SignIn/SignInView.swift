import DesignSystem
import SwiftUI

struct SignInView: View {
    @State private var model: SignInViewModel

    init(model: SignInViewModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        ZStack {
            AppBackground()
            NoteWall()
            VStack(spacing: 0) {
                Spacer()
                VStack(spacing: Spacing.space2) {
                    Text(String(localized: "Love Tunnel"))
                        .font(Typography.largeTitle)
                        .foregroundStyle(Palette.ink)
                    Text(String(localized: "Little notes for your person, right on their Home Screen."))
                        .font(Typography.body)
                        .foregroundStyle(Palette.inkMuted)
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.space4)
                .padding(.bottom, 11)
                VStack(spacing: Spacing.space4) {
                    SignInWithAppleButton(action: model.signIn)
                    TermsText()
                }
            }
            .padding(.horizontal, Spacing.space4)
        }
    }
}

#Preview {
    SignInView(model: SignInViewModel(navigator: .preview))
}
