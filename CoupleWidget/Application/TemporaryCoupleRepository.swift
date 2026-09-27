import Domain
import Foundation

struct TemporaryCoupleRepository: CoupleRepository {
    func join(inviteCode: String) async throws -> CoupleID {
        CoupleID(rawValue: UUID())
    }
}
