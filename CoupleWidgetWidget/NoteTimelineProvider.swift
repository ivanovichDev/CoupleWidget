import Foundation
import WidgetKit

nonisolated struct NoteTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> NoteEntry {
        NoteEntry(date: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping (NoteEntry) -> Void) {
        completion(NoteEntry(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NoteEntry>) -> Void) {
        completion(Timeline(entries: [NoteEntry(date: .now)], policy: .never))
    }
}
