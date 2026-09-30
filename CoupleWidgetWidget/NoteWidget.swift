import DesignSystem
import SwiftUI
import WidgetKit

struct NoteWidget: Widget {
    static let kind = "NoteWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: Self.kind, provider: NoteTimelineProvider()) { entry in
            NoteWidgetView(note: entry.note)
                .containerBackground(for: .widget) {
                    AppBackground()
                }
        }
        .configurationDisplayName(String(localized: "Couple Widget"))
        .description(String(localized: "The latest note from your partner."))
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabled()
        .pushHandler(NoteWidgetPushHandler.self)
    }
}
