import SwiftUI

struct SecondaryButtonLabel: View {
    let title: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .semibold))
            Text(title)
                .font(Typography.subheadline.weight(.semibold))
        }
        .foregroundStyle(Palette.roseStrong)
        .padding(.horizontal, Spacing.space4)
        .frame(height: 36)
        .glass(.control, in: .capsule)
    }
}
