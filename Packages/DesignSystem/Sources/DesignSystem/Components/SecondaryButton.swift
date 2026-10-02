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
            SecondaryButtonLabel(title: title, systemImage: systemImage)
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
