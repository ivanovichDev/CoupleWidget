public protocol RegisterPushTokenUseCase: Sendable {
    func callAsFunction(_ token: PushToken) async throws
}

public struct AppRegisterPushTokenUseCase: RegisterPushTokenUseCase {
    private let repository: PushTokenRepository

    public init(repository: PushTokenRepository) {
        self.repository = repository
    }

    public func callAsFunction(_ token: PushToken) async throws {
        try await repository.register(token)
    }
}
