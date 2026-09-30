import DesignSystem
import SwiftUI

struct LockedComposerLabel: View {
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: Spacing.space1) {
            Text(title)
                .foregroundStyle(Palette.inkMuted)
            Text(value)
                .fontWeight(.semibold)
                .monospacedDigit()
                .foregroundStyle(Palette.roseStrong)
        }
        .font(Typography.body)
        .lineLimit(1)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
