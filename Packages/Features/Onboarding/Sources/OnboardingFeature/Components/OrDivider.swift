import DesignSystem
import SwiftUI

struct OrDivider: View {
    var body: some View {
        HStack(spacing: Spacing.space3) {
            OrDividerLine()
            Text(String(localized: "or"))
                .font(Typography.footnote)
                .foregroundStyle(Palette.inkMuted)
            OrDividerLine()
        }
        .accessibilityHidden(true)
    }
}
