import Domain
import Foundation
import Testing

struct JoinCoupleUseCaseTests {
    @Test
    func trimsInviteCodeBeforeJoining() async throws {
        let repository = RecordingCoupleRepository()
        let useCase = AppJoinCoupleUseCase(repository: repository)

        _ = try await useCase(inviteCode: "  ABC123 \n")

        #expect(await repository.receivedCodes == ["ABC123"])
    }

    @Test
    func rejectsEmptyInviteCode() async {
        let useCase = AppJoinCoupleUseCase(repository: RecordingCoupleRepository())

        await #expect(throws: CoupleError.invalidInviteCode) {
            try await useCase(inviteCode: "   ")
        }
    }
}

private actor RecordingCoupleRepository: CoupleRepository {
    private(set) var receivedCodes: [String] = []

    func join(inviteCode: String) async throws -> CoupleID {
        receivedCodes.append(inviteCode)
        return CoupleID(rawValue: UUID())
    }

    func currentCouple() async throws -> CoupleID? {
        nil
    }
}
