import SwiftUI

public struct WidgetCard<Content: View, Footer: View>: View {
    private let padding: CGFloat
    private let blursBackdrop: Bool
    private let content: Content
    private let footer: Footer

    public init(
        padding: CGFloat = Spacing.space4,
        blursBackdrop: Bool = true,
        @ViewBuilder content: () -> Content,
        @ViewBuilder footer: () -> Footer
    ) {
        self.padding = padding
        self.blursBackdrop = blursBackdrop
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
        .glass(.card, in: .rect(cornerRadius: CornerRadius.widget), blursBackdrop: blursBackdrop)
    }
}

#Preview {
    WidgetCard {
        Text("Good morning, sunshine. Coffee is on the stove.")
            .font(Typography.headline)
            .foregroundStyle(Palette.ink)
    } footer: {
        NoteAuthorLabel("From Anna")
            .font(Typography.footnote)
    }
    .frame(width: 338, height: 158)
    .padding()
    .background { AppBackground() }
}
