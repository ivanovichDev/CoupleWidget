import Domain
import Foundation
import Testing
@testable import OnboardingFeature

@MainActor
struct InviteViewModelTests {
    @Test func successfulJoinReportsPairedCouple() async {
        let couple = CoupleID(rawValue: UUID())
        let recorder = NavigatorRecorder()
        let model = InviteViewModel(
            joinCouple: FakeJoinCoupleUseCase(result: .success(couple)),
            navigator: recorder.navigator
        )
        model.inviteCode = "ABC123"

        await model.join()

        #expect(model.state == .idle)
        #expect(recorder.outputs == [.paired(couple)])
    }

    @Test func invalidCodeShowsError() async {
        let recorder = NavigatorRecorder()
        let model = InviteViewModel(
            joinCouple: FakeJoinCoupleUseCase(result: .failure(.invalidInviteCode)),
            navigator: recorder.navigator
        )

        await model.join()

        guard case .failed = model.state else {
            Issue.record("Expected failed state, got \(model.state)")
            return
        }
        #expect(recorder.outputs.isEmpty)
    }
}

private struct FakeJoinCoupleUseCase: JoinCoupleUseCase {
    let result: Result<CoupleID, CoupleError>

    func callAsFunction(inviteCode: String) async throws -> CoupleID {
        try result.get()
    }
}
