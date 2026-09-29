import DesignSystem
import SwiftUI
import WidgetKit

struct NoteWidgetView: View {
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
            Text(String(localized: "Your partner hasn't left any notes yet"))
                .font(size.textFont)
                .foregroundStyle(Palette.inkMuted)
                .lineLimit(size.lineLimit)
        } footer: {
            EmptyView()
        }
    }
}

#Preview(as: .systemSmall) {
    NoteWidget()
} timeline: {
    NoteEntry(date: .now)
}

#Preview(as: .systemMedium) {
    NoteWidget()
} timeline: {
    NoteEntry(date: .now)
}

#Preview(as: .systemLarge) {
    NoteWidget()
} timeline: {
    NoteEntry(date: .now)
}
