import Foundation
import NoteCache
import WidgetKit

nonisolated struct NoteEntry: TimelineEntry {
    let date: Date
    let note: CachedNote?
}
