import DesignSystem
import SwiftUI

struct NotesLeftBadge: View {
    let text: String
    let isExhausted: Bool
    let accessibilityText: String

    var body: some View {
        Text(text)
            .font(Font.caption.weight(.semibold))
            .monospacedDigit()
            .foregroundStyle(isExhausted ? Palette.onRose : Palette.roseStrong)
            .padding(.horizontal, Spacing.space2)
            .frame(height: 20)
            .background(isExhausted ? Palette.roseStrong : Palette.roseStrong.opacity(0.12), in: .capsule)
            .accessibilityLabel(accessibilityText)
    }
}

#Preview {
    VStack(spacing: Spacing.space2) {
        NotesLeftBadge(text: "7/10", isExhausted: false, accessibilityText: "7 of 10 notes left today")
        NotesLeftBadge(text: "0/10", isExhausted: true, accessibilityText: "0 of 10 notes left today")
        NotesLeftBadge(text: "∞", isExhausted: false, accessibilityText: "Unlimited notes")
    }
    .padding()
}
