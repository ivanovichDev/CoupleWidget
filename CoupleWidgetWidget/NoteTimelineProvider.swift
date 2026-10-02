import Domain
import Foundation
import NoteCache
import WidgetKit

nonisolated struct NoteTimelineProvider: TimelineProvider {
    private static let retryInterval: TimeInterval = 15 * 60

    private let store = NoteCacheStore()

    func placeholder(in context: Context) -> NoteEntry {
        NoteEntry(date: .now, note: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (NoteEntry) -> Void) {
        completion(NoteEntry(date: .now, note: store?.read()))
    }

    func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<NoteEntry>) -> Void) {
        Task {
            completion(await refreshedTimeline())
        }
    }

    private func refreshedTimeline() async -> Timeline<NoteEntry> {
        guard
            let container = WidgetContainer(),
            let secret = container.secretStore?.read()
        else {
            return timeline(policy: .never)
        }
        do {
            if let fetched = try await container.fetchPartnerNote(secret: secret) {
                let note = CachedNote(authorName: fetched.authorName, text: fetched.text, updatedAt: fetched.updatedAt)
                _ = try? store?.save(note)
            }
            return timeline(policy: .never)
        } catch {
            return timeline(policy: .after(.now.addingTimeInterval(Self.retryInterval)))
        }
    }

    private func timeline(policy: TimelineReloadPolicy) -> Timeline<NoteEntry> {
        Timeline(entries: [NoteEntry(date: .now, note: store?.read())], policy: policy)
    }
}
