public protocol MessageQuotaUseCase: Sendable {
    func callAsFunction() async throws -> MessageQuota
}

public struct AppMessageQuotaUseCase: MessageQuotaUseCase {
    private let repository: MessageRepository

    public init(repository: MessageRepository) {
        self.repository = repository
    }

    public func callAsFunction() async throws -> MessageQuota {
        try await repository.quota()
    }
}
