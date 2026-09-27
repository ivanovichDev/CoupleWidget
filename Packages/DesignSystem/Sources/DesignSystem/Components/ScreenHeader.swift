import SwiftUI

public struct ScreenHeader: View {
    private let title: String
    private let subtitle: String

    public init(title: String, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
    }

    public var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(Typography.largeTitle)
                .foregroundStyle(Palette.ink)
            Text(subtitle)
                .font(Typography.body)
                .foregroundStyle(Palette.inkMuted)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Spacing.space1)
    }
}

#Preview {
    ScreenHeader(title: "What’s your name?", subtitle: "Your partner will see it on every note.")
        .padding()
}
