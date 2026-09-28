import Domain
import Foundation
import Testing
@testable import OnboardingFeature

@MainActor
struct InviteViewModelTests {
    @Test
    func partnerCodeIsUppercasedTrimmedAndLimited() {
        let model = InviteViewModel(
            pairingCode: "K7M2QX",
            joinCouple: FakeJoinCoupleUseCase(result: .success(CoupleID(rawValue: UUID()))),
            navigator: NavigatorRecorder().navigator
        )

        model.partnerCode = "ab c1 23xyz"
        model.normalizePartnerCode()

        #expect(model.partnerCode == "ABC123")
    }

    @Test
    func connectRequiresFullCode() async {
        let recorder = NavigatorRecorder()
        let model = InviteViewModel(
            pairingCode: "K7M2QX",
            joinCouple: FakeJoinCoupleUseCase(result: .success(CoupleID(rawValue: UUID()))),
            navigator: recorder.navigator
        )
        model.partnerCode = "ABC"

        await model.connect()

        #expect(!model.canConnect)
        #expect(recorder.outputs.isEmpty)
    }

    @Test
    func successfulConnectReportsPairedCouple() async {
        let couple = CoupleID(rawValue: UUID())
        let recorder = NavigatorRecorder()
        let model = InviteViewModel(
            pairingCode: "K7M2QX",
            joinCouple: FakeJoinCoupleUseCase(result: .success(couple)),
            navigator: recorder.navigator
        )
        model.partnerCode = "ABC123"

        await model.connect()

        #expect(model.state == .idle)
        #expect(recorder.outputs == [.paired(couple)])
    }

    @Test
    func invalidCodeSetsFailedState() async {
        let recorder = NavigatorRecorder()
        let model = InviteViewModel(
            pairingCode: "K7M2QX",
            joinCouple: FakeJoinCoupleUseCase(result: .failure(.invalidInviteCode)),
            navigator: recorder.navigator
        )
        model.partnerCode = "ABC123"

        await model.connect()

        guard case .failed = model.state else {
            Issue.record("Expected failed state, got \(model.state)")
            return
        }
        #expect(recorder.outputs.isEmpty)
    }

    @Test
    func ownCodeIsSplitWithMiddleDot() {
        let model = InviteViewModel(
            pairingCode: "K7M2QX",
            joinCouple: FakeJoinCoupleUseCase(result: .success(CoupleID(rawValue: UUID()))),
            navigator: NavigatorRecorder().navigator
        )

        #expect(model.formattedOwnCode == "K7M·2QX")
    }
}

private struct FakeJoinCoupleUseCase: JoinCoupleUseCase {
    let result: Result<CoupleID, CoupleError>

    func callAsFunction(inviteCode: String) async throws -> CoupleID {
        try result.get()
    }
}
