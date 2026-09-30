public protocol CoupleRepository: Sendable {
    func join(inviteCode: String) async throws -> CoupleID
    func currentCouple() async throws -> CoupleID?
    func partnerName() async throws -> String
}
