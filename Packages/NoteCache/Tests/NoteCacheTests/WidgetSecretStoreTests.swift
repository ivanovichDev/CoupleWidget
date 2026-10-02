import Foundation
import NoteCache
import Testing

struct WidgetSecretStoreTests {
    private let store: WidgetSecretStore

    init() throws {
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        store = WidgetSecretStore(directory: directory)
    }

    @Test
    func returnsNothingWhenEmpty() {
        #expect(store.read() == nil)
    }

    @Test
    func createsSecretOfSixtyFourHexCharacters() throws {
        let secret = try store.readOrCreate()

        #expect(secret.count == 64)
        #expect(secret.allSatisfy { $0.isHexDigit })
    }

    @Test
    func keepsTheSameSecret() throws {
        let first = try store.readOrCreate()
        let second = try store.readOrCreate()

        #expect(first == second)
        #expect(store.read() == first)
    }
}
