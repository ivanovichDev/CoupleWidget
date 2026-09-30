import Foundation
import NoteCache
import WidgetKit

nonisolated struct NoteTimelineProvider: TimelineProvider {
    private let store = NoteCacheStore()

    func placeholder(in context: Context) -> NoteEntry {
        NoteEntry(date: .now, note: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (NoteEntry) -> Void) {
        completion(NoteEntry(date: .now, note: store?.read()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NoteEntry>) -> Void) {
        completion(Timeline(entries: [NoteEntry(date: .now, note: store?.read())], policy: .never))
    }
}
