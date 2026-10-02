public protocol WidgetSecretRepository: Sendable {
    func register(secret: String, environment: PushEnvironment, pushToken: String?) async throws
}
