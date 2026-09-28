public protocol SignInWithAppleUseCase: Sendable {
    func callAsFunction() async throws -> UserID
}

public struct AppSignInWithAppleUseCase: SignInWithAppleUseCase {
    private let repository: SessionRepository

    public init(repository: SessionRepository) {
        self.repository = repository
    }

    public func callAsFunction() async throws -> UserID {
        try await repository.signInWithApple()
    }
}
