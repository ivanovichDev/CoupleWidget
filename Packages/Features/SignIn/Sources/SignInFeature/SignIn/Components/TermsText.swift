import DesignSystem
import SwiftUI

struct TermsText: View {
    private var terms: AttributedString {
        var text = AttributedString(localized: "By continuing you agree to our Terms and Privacy Policy.")
        for word in [String(localized: "Terms"), String(localized: "Privacy Policy")] {
            if let range = text.range(of: word) {
                text[range].foregroundColor = Palette.roseStrong
            }
        }
        return text
    }

    var body: some View {
        Text(terms)
            .font(Typography.footnote)
            .foregroundStyle(Palette.inkMuted)
            .multilineTextAlignment(.center)
            .padding(.horizontal, Spacing.space4)
    }
}
