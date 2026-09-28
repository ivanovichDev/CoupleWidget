public protocol SessionRepository: Sendable {
    func signInWithApple() async throws -> UserID
    func currentUser() async -> UserID?
}
