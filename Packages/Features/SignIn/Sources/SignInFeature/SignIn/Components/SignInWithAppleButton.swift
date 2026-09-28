import DesignSystem
import SwiftUI

struct SignInWithAppleButton: View {
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
