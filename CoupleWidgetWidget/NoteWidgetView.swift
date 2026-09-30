import DesignSystem
import NoteCache
import SwiftUI
import WidgetKit

struct NoteWidgetView: View {
    let note: CachedNote?

    @Environment(\.widgetFamily)
    private var family

    private var size: WidgetSize {
        switch family {
        case .systemMedium: .medium
        case .systemLarge: .large
        default: .small
        }
    }

    var body: some View {
        WidgetCardLayout {
            Text(note?.text ?? String(localized: "Your partner hasn't left any notes yet"))
                .font(size.textFont)
                .foregroundStyle(note == nil ? Palette.inkMuted : Palette.ink)
                .lineLimit(size.lineLimit)
        } footer: {
            if let note {
                NoteAuthorLabel(String(localized: "From \(note.authorName)"))
                    .font(size.footerFont)
            }
        }
    }
}

#Preview(as: .systemSmall) {
    NoteWidget()
} timeline: {
    NoteEntry(date: .now, note: nil)
    NoteEntry(date: .now, note: CachedNote(authorName: "Anna", text: "Miss you", updatedAt: .now))
}

#Preview(as: .systemMedium) {
    NoteWidget()
} timeline: {
    NoteEntry(date: .now, note: nil)
    NoteEntry(date: .now, note: CachedNote(authorName: "Anna", text: "Miss you", updatedAt: .now))
}

#Preview(as: .systemLarge) {
    NoteWidget()
} timeline: {
    NoteEntry(date: .now, note: nil)
    NoteEntry(date: .now, note: CachedNote(authorName: "Anna", text: "Miss you", updatedAt: .now))
}
