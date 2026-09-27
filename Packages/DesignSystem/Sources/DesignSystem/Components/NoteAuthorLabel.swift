import SwiftUI

public struct NoteAuthorLabel: View {
    private let text: String
    private let heartSize: CGFloat
    private let spacing: CGFloat

    public init(_ text: String, heartSize: CGFloat = 14, spacing: CGFloat = 6) {
        self.text = text
        self.heartSize = heartSize
        self.spacing = spacing
    }

    public var body: some View {
        HStack(spacing: spacing) {
            HeartShape()
                .fill(Palette.roseStrong)
                .frame(width: heartSize, height: heartSize)
            Text(text)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .foregroundStyle(Palette.inkMuted)
    }
}

#Preview {
    NoteAuthorLabel("From Anna")
        .font(Typography.footnote)
        .padding()
}
