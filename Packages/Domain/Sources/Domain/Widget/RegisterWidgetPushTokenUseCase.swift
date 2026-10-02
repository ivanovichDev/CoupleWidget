public protocol RegisterWidgetPushTokenUseCase: Sendable {
    func callAsFunction(_ token: String, secret: String) async throws
}

public struct AppRegisterWidgetPushTokenUseCase: RegisterWidgetPushTokenUseCase {
    private let repository: WidgetNoteRepository

    public init(repository: WidgetNoteRepository) {
        self.repository = repository
    }

    public func callAsFunction(_ token: String, secret: String) async throws {
        try await repository.registerPushToken(token, secret: secret)
    }
}
