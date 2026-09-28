import SwiftUI

public struct ScreenLayout<Content: View, Input: View, Actions: View>: View {
    private let step: Int
    private let totalSteps: Int
    private let title: String
    private let subtitle: String
    private let contentSpacing: CGFloat
    private let content: Content
    private let input: Input
    private let actions: Actions

    public init(
        step: Int,
        of totalSteps: Int,
        title: String,
        subtitle: String,
        contentSpacing: CGFloat,
        @ViewBuilder content: () -> Content,
        @ViewBuilder input: () -> Input,
        @ViewBuilder actions: () -> Actions
    ) {
        self.step = step
        self.totalSteps = totalSteps
        self.title = title
        self.subtitle = subtitle
        self.contentSpacing = contentSpacing
        self.content = content()
        self.input = input()
        self.actions = actions()
    }

    public var body: some View {
        ScreenLayoutColumn(
            step: step,
            totalSteps: totalSteps,
            title: title,
            subtitle: subtitle,
            contentSpacing: contentSpacing,
            content: content,
            input: input,
            actions: actions
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .dismissesKeyboardOnTap()
        .ignoresKeyboardLayout()
        .ignoresSafeArea(.keyboard)
        .background { AppBackground() }
    }
}

extension ScreenLayout where Input == EmptyView {
    public init(
        step: Int,
        of totalSteps: Int,
        title: String,
        subtitle: String,
        contentSpacing: CGFloat,
        @ViewBuilder content: () -> Content,
        @ViewBuilder actions: () -> Actions
    ) {
        self.init(
            step: step,
            of: totalSteps,
            title: title,
            subtitle: subtitle,
            contentSpacing: contentSpacing,
            content: content,
            input: { EmptyView() },
            actions: actions
        )
    }
}

#Preview {
    ScreenLayout(
        step: 1,
        of: 3,
        title: "What’s your name?",
        subtitle: "Your partner will see it on every note.",
        contentSpacing: 19
    ) {
        Text("Content")
    } actions: {
        PrimaryButton(title: "Continue") {}
    }
}
