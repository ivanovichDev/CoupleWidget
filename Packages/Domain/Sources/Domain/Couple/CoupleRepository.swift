public protocol CoupleRepository: Sendable {
    func join(inviteCode: String) async throws -> CoupleID
}
