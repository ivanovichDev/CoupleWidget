import SwiftUI

public struct WidgetCardLayout<Content: View, Footer: View>: View {
    private let padding: CGFloat
    private let content: Content
    private let footer: Footer

    public init(
        padding: CGFloat = Spacing.space4,
        @ViewBuilder content: () -> Content,
        @ViewBuilder footer: () -> Footer
    ) {
        self.padding = padding
        self.content = content()
        self.footer = footer()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.space2) {
            content
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer(minLength: 0)
            footer
        }
        .padding(padding)
    }
}
