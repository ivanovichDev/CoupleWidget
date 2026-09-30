import Foundation
import NoteCache
import Testing

struct WidgetPushTokenStoreTests {
    private let store: WidgetPushTokenStore

    init() throws {
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        store = WidgetPushTokenStore(directory: directory)
    }

    @Test
    func returnsNothingWhenEmpty() {
        #expect(store.read() == nil)
    }

    @Test
    func readsLatestSavedToken() throws {
        try store.save("a1b2")
        try store.save("c3d4")

        #expect(store.read() == "c3d4")
    }
}
