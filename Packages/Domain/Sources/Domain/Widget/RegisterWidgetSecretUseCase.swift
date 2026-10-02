public protocol RegisterWidgetSecretUseCase: Sendable {
    func callAsFunction(secret: String, environment: PushEnvironment, pushToken: String?) async throws
}

public struct AppRegisterWidgetSecretUseCase: RegisterWidgetSecretUseCase {
    private let repository: WidgetSecretRepository

    public init(repository: WidgetSecretRepository) {
        self.repository = repository
    }

    public func callAsFunction(secret: String, environment: PushEnvironment, pushToken: String?) async throws {
        try await repository.register(secret: secret, environment: environment, pushToken: pushToken)
    }
}
