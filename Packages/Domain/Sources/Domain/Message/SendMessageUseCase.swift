import Foundation

public protocol SendMessageUseCase: Sendable {
    func callAsFunction(_ text: String) async throws -> MessageQuota
}

public struct AppSendMessageUseCase: SendMessageUseCase {
    private let repository: MessageRepository

    public init(repository: MessageRepository) {
        self.repository = repository
    }

    public func callAsFunction(_ text: String) async throws -> MessageQuota {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw MessageError.empty }
        return try await repository.send(trimmed)
    }
}
