import Foundation

public struct PartnerNote: Equatable, Sendable {
    public let authorName: String
    public let text: String
    public let updatedAt: Date

    public init(authorName: String, text: String, updatedAt: Date) {
        self.authorName = authorName
        self.text = text
        self.updatedAt = updatedAt
    }
}
