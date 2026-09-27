import Foundation

public struct Message: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let authorID: UserID
    public let text: String
    public let sentAt: Date

    public init(id: UUID, authorID: UserID, text: String, sentAt: Date) {
        self.id = id
        self.authorID = authorID
        self.text = text
        self.sentAt = sentAt
    }
}
