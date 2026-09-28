import Domain
import Foundation
import Testing
@testable import OnboardingFeature

@MainActor
struct InviteViewModelTests {
    @Test
    func partnerCodeIsUppercasedTrimmedAndLimited() {
        let model = makeModel(recorder: NavigatorRecorder())

        model.partnerCode = "ab c1 23xyz"
        model.normalizePartnerCode()

        #expect(model.partnerCode == "ABC123")
    }

    @Test
    func connectRequiresFullCode() async {
        let recorder = NavigatorRecorder()
        let model = makeModel(recorder: recorder)
        model.partnerCode = "ABC"

        await model.connect()

        #expect(!model.canConnect)
        #expect(recorder.outputs.isEmpty)
    }

    @Test
    func successfulConnectReportsPairedCouple() async {
        let couple = CoupleID(rawValue: UUID())
        let recorder = NavigatorRecorder()
        let model = makeModel(join: .success(couple), recorder: recorder)
        model.partnerCode = "ABC123"

        await model.connect()

        #expect(model.state == .idle)
        #expect(recorder.outputs == [.paired(couple)])
    }

    @Test(arguments: [
        (CoupleError.ownInviteCode, "That’s your own code. Enter your partner’s code."),
        (CoupleError.inviteCodeNotFound, "No one has this code. Check it and try again."),
        (CoupleError.partnerAlreadyPaired, "This person is already paired with someone else.")
    ])
    func failedConnectShowsAlert(error: CoupleError, message: String) async {
        let recorder = NavigatorRecorder()
        let model = makeModel(join: .failure(error), recorder: recorder)
        model.partnerCode = "ABC123"

        await model.connect()

        #expect(model.alertMessage == message)
        #expect(model.isAlertPresented)
        #expect(model.state == .idle)
        #expect(recorder.outputs.isEmpty)
    }

    @Test
    func dismissingAlertClearsMessage() async {
        let model = makeModel(join: .failure(.inviteCodeNotFound), recorder: NavigatorRecorder())
        model.partnerCode = "ABC123"
        await model.connect()

        model.isAlertPresented = false

        #expect(model.alertMessage == nil)
    }

    @Test
    func checkPairingOpensHomeWhenPaired() async {
        let couple = CoupleID(rawValue: UUID())
        let recorder = NavigatorRecorder()
        let model = makeModel(current: couple, recorder: recorder)

        await model.checkPairing()

        #expect(recorder.outputs == [.paired(couple)])
        #expect(model.alertMessage == nil)
        #expect(model.state == .idle)
    }

    @Test
    func checkPairingShowsAlertWhenNotPaired() async {
        let recorder = NavigatorRecorder()
        let model = makeModel(current: nil, recorder: recorder)

        await model.checkPairing()

        #expect(recorder.outputs.isEmpty)
        #expect(model.alertMessage == "Your partner hasn’t connected yet.")
        #expect(model.state == .idle)
    }

    @Test
    func ownCodeIsSplitWithMiddleDot() {
        let model = makeModel(recorder: NavigatorRecorder())

        #expect(model.formattedOwnCode == "K7M·2QX")
    }

    private func makeModel(
        join: Result<CoupleID, CoupleError> = .success(CoupleID(rawValue: UUID())),
        current: CoupleID? = nil,
        recorder: NavigatorRecorder
    ) -> InviteViewModel {
        InviteViewModel(
            pairingCode: "K7M2QX",
            joinCouple: FakeJoinCoupleUseCase(result: join),
            currentCouple: FakeCurrentCoupleUseCase(couple: current),
            navigator: recorder.navigator
        )
    }
}

private struct FakeJoinCoupleUseCase: JoinCoupleUseCase {
    let result: Result<CoupleID, CoupleError>

    func callAsFunction(inviteCode: String) async throws -> CoupleID {
        try result.get()
    }
}

private struct FakeCurrentCoupleUseCase: CurrentCoupleUseCase {
    let couple: CoupleID?

    func callAsFunction() async throws -> CoupleID? {
        couple
    }
}
