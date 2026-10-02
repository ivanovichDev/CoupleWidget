import Foundation

public struct WidgetSecretStore: Sendable {
    private let fileURL: URL

    public init(directory: URL) {
        fileURL = directory.appending(path: "widget-secret")
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
        guard let secret = try? String(contentsOf: fileURL, encoding: .utf8), !secret.isEmpty else {
            return nil
        }
        return secret
    }

    public func readOrCreate() throws -> String {
        if let secret = read() {
            return secret
        }
        let secret = (0..<32)
            .map { _ in String(format: "%02x", UInt8.random(in: .min ... .max)) }
            .joined()
        try Data(secret.utf8).write(to: fileURL, options: .atomic)
        return secret
    }
}
