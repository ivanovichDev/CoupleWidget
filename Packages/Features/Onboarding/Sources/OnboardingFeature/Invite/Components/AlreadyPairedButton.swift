import DesignSystem
import SwiftUI

struct AlreadyPairedButton: View {
    let isChecking: Bool
    let action: () -> Void

    private var title: AttributedString {
        var text = AttributedString(localized: "Already added by your partner? Check")
        if let range = text.range(of: String(localized: "Check")) {
            text[range].foregroundColor = Palette.roseStrong
        }
        return text
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                Text(title)
                    .font(Typography.footnote)
                    .foregroundStyle(Palette.inkMuted)
                    .opacity(isChecking ? 0 : 1)
                if isChecking {
                    ProgressView()
                        .tint(Palette.roseStrong)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(isChecking)
    }
}
