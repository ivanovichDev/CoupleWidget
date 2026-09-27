import DesignSystem
import SwiftUI

struct OrDivider: View {
    var body: some View {
        HStack(spacing: Spacing.space3) {
            line
            Text(String(localized: "or"))
                .font(Typography.footnote)
                .foregroundStyle(Palette.inkMuted)
            line
        }
        .accessibilityHidden(true)
    }

    private var line: some View {
        Rectangle()
            .fill(Palette.rose.opacity(0.22))
            .frame(height: 1)
    }
}
