import SwiftUI

public struct ScreenLayout<Content: View, Actions: View>: View {
    private let title: String
    private let subtitle: String?
    private let content: Content
    private let actions: Actions

    public init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder content: () -> Content,
        @ViewBuilder actions: () -> Actions
    ) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
        self.actions = actions()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.large) {
            VStack(alignment: .leading, spacing: Spacing.small) {
                Text(title)
                    .font(.largeTitle.bold())
                if let subtitle {
                    Text(subtitle)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }
            content
            Spacer(minLength: 0)
            actions
        }
        .padding(Spacing.medium)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

#Preview {
    ScreenLayout(title: "Title", subtitle: "Subtitle") {
        Text("Content")
    } actions: {
        PrimaryButton(title: "Continue") {}
    }
}
