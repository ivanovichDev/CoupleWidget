import SwiftUI

public struct NoteCard: View {
    private let text: String
    private let author: String
    private let time: String

    public init(text: String, author: String, time: String) {
        self.text = text
        self.author = author
        self.time = time
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.space2) {
            Text(text)
                .font(Typography.body)
            Text("\(author) · \(time)")
                .font(Typography.footnote)
        }
        .foregroundStyle(Palette.ink)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.space4)
        .background(Palette.peach, in: .rect(cornerRadius: CornerRadius.container))
    }
}

#Preview {
    VStack(spacing: Spacing.space3) {
        NoteCard(text: "Good morning, sunshine. Coffee is on the stove.", author: "You", time: "8:15 AM")
        NoteCard(text: "Can’t wait for tonight, I got the tickets", author: "You", time: "Yesterday")
    }
    .padding(Spacing.space4)
    .background(Palette.background)
}
