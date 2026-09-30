import Foundation

public struct WidgetPushTokenStore: Sendable {
    private let fileURL: URL

    public init(directory: URL) {
        fileURL = directory.appending(path: "widget-push-token")
    }

    public init?(appGroupIdentifier: String = NoteCacheStore.appGroupIdentifier) {
        guard let directory = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupIdentifier
        ) else {
            return nil
        }
        self.init(directory: directory)
    }

    public func read() -> String? {
        guard let token = try? String(contentsOf: fileURL, encoding: .utf8), !token.isEmpty else {
            return nil
        }
        return token
    }

    public func save(_ token: String) throws {
        try Data(token.utf8).write(to: fileURL, options: .atomic)
    }
}
