public protocol PushTokenRepository: Sendable {
    func register(_ token: PushToken) async throws
}
