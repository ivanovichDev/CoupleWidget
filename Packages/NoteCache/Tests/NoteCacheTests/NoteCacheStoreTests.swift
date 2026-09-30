import Foundation
import NoteCache
import Testing

struct NoteCacheStoreTests {
    private let store: NoteCacheStore

    init() throws {
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        store = NoteCacheStore(directory: directory)
    }

    @Test
    func returnsNothingWhenEmpty() {
        #expect(store.read() == nil)
    }

    @Test
    func readsSavedNote() throws {
        let note = CachedNote(authorName: "Anna", text: "Miss you", updatedAt: Date(timeIntervalSince1970: 100))

        #expect(try store.save(note))
        #expect(store.read() == note)
    }

    @Test
    func replacesNoteWithNewerOne() throws {
        let older = CachedNote(authorName: "Anna", text: "Good morning", updatedAt: Date(timeIntervalSince1970: 100))
        let newer = CachedNote(authorName: "Anna", text: "Miss you", updatedAt: Date(timeIntervalSince1970: 200))

        try store.save(older)

        #expect(try store.save(newer))
        #expect(store.read() == newer)
    }

    @Test
    func keepsNoteWhenIncomingOneIsOlder() throws {
        let newer = CachedNote(authorName: "Anna", text: "Miss you", updatedAt: Date(timeIntervalSince1970: 200))
        let older = CachedNote(authorName: "Anna", text: "Good morning", updatedAt: Date(timeIntervalSince1970: 100))

        try store.save(newer)

        #expect(try !store.save(older))
        #expect(store.read() == newer)
    }

    @Test
    func keepsNoteWhenIncomingOneHasSameVersion() throws {
        let stored = CachedNote(authorName: "Anna", text: "Miss you", updatedAt: Date(timeIntervalSince1970: 200))
        let duplicate = CachedNote(authorName: "Anna", text: "Other", updatedAt: Date(timeIntervalSince1970: 200))

        try store.save(stored)

        #expect(try !store.save(duplicate))
        #expect(store.read() == stored)
    }
}
