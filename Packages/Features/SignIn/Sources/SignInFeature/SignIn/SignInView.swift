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

private struct SignInWithAppleButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "apple.logo")
                    .font(.system(size: 22))
                    .offset(y: -1)
                Text(String(localized: "Sign in with Apple"))
                    .font(.system(size: 21, weight: .medium))
                    .tracking(-0.2)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(.black, in: .capsule)
            .shadow(color: Palette.ink.opacity(0.25), radius: 15, y: 10)
        }
        .buttonStyle(.plain)
    }
}

private struct TermsText: View {
    var body: some View {
        Text(terms)
            .font(Typography.footnote)
            .foregroundStyle(Palette.inkMuted)
            .multilineTextAlignment(.center)
            .padding(.horizontal, Spacing.space4)
    }

    private var terms: AttributedString {
        var text = AttributedString(localized: "By continuing you agree to our Terms and Privacy Policy.")
        for word in [String(localized: "Terms"), String(localized: "Privacy Policy")] {
            if let range = text.range(of: word) {
                text[range].foregroundColor = Palette.roseStrong
            }
        }
        return text
    }
}

#Preview {
    SignInView(model: SignInViewModel(navigator: .preview))
}
