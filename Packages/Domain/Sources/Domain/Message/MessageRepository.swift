public protocol MessageRepository: Sendable {
    func quota() async throws -> MessageQuota
    func send(_ text: String) async throws -> MessageQuota
}
