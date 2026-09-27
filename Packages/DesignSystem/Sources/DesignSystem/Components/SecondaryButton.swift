import SwiftUI

public struct SecondaryButton: View {
    private let title: String
    private let systemImage: String
    private let action: () -> Void

    public init(title: String, systemImage: String, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
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
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack(spacing: Spacing.space2) {
        SecondaryButton(title: "Copy", systemImage: "doc.on.doc") {}
        SecondaryButton(title: "Share", systemImage: "square.and.arrow.up") {}
    }
    .padding()
    .background { AppBackground() }
}
