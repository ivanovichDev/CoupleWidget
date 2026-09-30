import Foundation

public struct NoteCacheStore: Sendable {
    public static let appGroupIdentifier = "group.com.ivanovich.couplewidget"

    private let fileURL: URL

    public init(directory: URL) {
        fileURL = directory.appending(path: "latest-note.json")
    }

    public init?(appGroupIdentifier: String = Self.appGroupIdentifier) {
        guard let directory = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupIdentifier
        ) else {
            return nil
        }
        self.init(directory: directory)
    }

    public func read() -> CachedNote? {
        var note: CachedNote?
        var coordinationError: NSError?
        NSFileCoordinator().coordinate(readingItemAt: fileURL, options: [], error: &coordinationError) { url in
            note = Self.note(at: url)
        }
        return note
    }

    @discardableResult
    public func save(_ note: CachedNote) throws -> Bool {
        var isSaved = false
        var writeError: (any Error)?
        var coordinationError: NSError?
        NSFileCoordinator().coordinate(
            writingItemAt: fileURL,
            options: .forReplacing,
            error: &coordinationError
        ) { url in
            if let stored = Self.note(at: url), stored.updatedAt >= note.updatedAt {
                return
            }
            do {
                let file = NoteCacheFile(schemaVersion: NoteCacheFile.currentSchemaVersion, note: note)
                try JSONEncoder().encode(file).write(to: url, options: .atomic)
                isSaved = true
            } catch {
                writeError = error
            }
        }
        if let error = coordinationError ?? writeError {
            throw error
        }
        return isSaved
    }

    private static func note(at url: URL) -> CachedNote? {
        guard
            let data = try? Data(contentsOf: url),
            let file = try? JSONDecoder().decode(NoteCacheFile.self, from: data),
            file.schemaVersion == NoteCacheFile.currentSchemaVersion
        else {
            return nil
        }
        return file.note
    }
}
