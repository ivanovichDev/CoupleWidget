struct NoteCacheFile: Codable {
    static let currentSchemaVersion = 1

    let schemaVersion: Int
    let note: CachedNote
}
