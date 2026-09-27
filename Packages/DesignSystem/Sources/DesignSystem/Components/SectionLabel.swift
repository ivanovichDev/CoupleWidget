import SwiftUI

public struct SectionLabel: View {
    private let text: String

    public init(_ text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .font(Typography.footnote.weight(.semibold))
            .tracking(0.4)
            .textCase(.uppercase)
            .foregroundStyle(Palette.inkMuted)
    }
}

#Preview {
    SectionLabel("Your code")
        .padding()
}
