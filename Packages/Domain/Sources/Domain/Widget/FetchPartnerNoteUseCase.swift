public protocol FetchPartnerNoteUseCase: Sendable {
    func callAsFunction(secret: String) async throws -> PartnerNote?
}

public struct AppFetchPartnerNoteUseCase: FetchPartnerNoteUseCase {
    private let repository: WidgetNoteRepository

    public init(repository: WidgetNoteRepository) {
        self.repository = repository
    }

    public func callAsFunction(secret: String) async throws -> PartnerNote? {
        try await repository.latestPartnerNote(secret: secret)
    }
}
