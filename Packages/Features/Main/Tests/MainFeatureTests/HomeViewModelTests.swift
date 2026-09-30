import Domain
import Foundation
import Testing
@testable import MainFeature

@MainActor
struct HomeViewModelTests {
    @Test
    func blankDraftIsNotSent() async {
        let sender = RecordingSendMessageUseCase()
        let model = makeModel(sendMessage: sender)
        model.draft = "   \n"

        await model.send()

        #expect(!model.canSend)
        #expect(model.draft == "   \n")
        #expect(await sender.sentTexts.isEmpty)
    }

    @Test
    func sendingClearsDraftAndLocksComposerWithServerCooldown() async {
        let sender = RecordingSendMessageUseCase(result: .success(.stub(left: 6, cooldownRemaining: 30)))
        let model = makeModel(sendMessage: sender)
        model.draft = "  Miss you  "

        await model.send()

        #expect(await sender.sentTexts == ["Miss you"])
        #expect(model.draft.isEmpty)
        #expect(model.notesLeft == "6/10")
        #expect(model.composerLock?.title == "Next note in")
        #expect(model.composerLock?.value == "0:30")
    }

    @Test
    func failedSendRestoresDraftAndShowsError() async {
        let sender = RecordingSendMessageUseCase(result: .failure(MessageError.dailyLimitReached))
        let quota = StubMessageQuotaUseCase(quota: .stub(left: 0, cooldownRemaining: 0))
        let model = makeModel(messageQuota: quota, sendMessage: sender)
        model.draft = "Miss you"

        await model.send()

        #expect(model.draft == "Miss you")
        #expect(model.errorMessage == "You have sent all your notes for today.")
        #expect(model.notesLeft == "0/10")
        #expect(model.isLimitReached)
    }

    @Test
    func reachedLimitLocksComposerUntilReset() {
        let model = makeModel(quota: .stub(left: 0, cooldownRemaining: 0, resetRemaining: 3661))

        #expect(model.isLimitReached)
        #expect(!model.canSend)
        #expect(model.composerLock?.title == "Limits reset in")
        #expect(model.composerLock?.value == "01:01:01")
        #expect(model.composerLock?.countdown == nil)
    }

    @Test
    func unlimitedPlanShowsInfinity() {
        let model = makeModel(quota: MessageQuota(
            dailyLimit: nil,
            messagesLeft: nil,
            cooldown: 30,
            cooldownRemaining: 0,
            resetRemaining: 100
        ))

        #expect(model.notesLeft == "∞")
        #expect(model.composerLock == nil)
    }

    @Test
    func draftIsLimitedToMaxLength() {
        let model = makeModel()
        model.draft = String(repeating: "a", count: 200)

        model.limitDraft()

        #expect(model.draft.count == HomeViewModel.maxNoteLength)
    }

    @Test
    func lineBreaksAreRemovedAndReported() {
        let model = makeModel()
        model.draft = "Miss you\n"

        #expect(model.removeLineBreaks())
        #expect(model.draft == "Miss you")
    }

    @Test
    func draftWithoutLineBreaksIsUntouched() {
        let model = makeModel()
        model.draft = "Miss you"

        #expect(!model.removeLineBreaks())
        #expect(model.draft == "Miss you")
    }

    @Test
    func pickingQuickNoteReplacesDraft() {
        let model = makeModel()
        model.draft = "Hello"

        model.pickQuickNote(QuickNote(text: "Miss you"))

        #expect(model.draft == "Miss you")
    }

    private func makeModel(
        quota: MessageQuota? = .stub(left: 7, cooldownRemaining: 0),
        messageQuota: MessageQuotaUseCase = StubMessageQuotaUseCase(quota: .stub(left: 7, cooldownRemaining: 0)),
        sendMessage: SendMessageUseCase = RecordingSendMessageUseCase()
    ) -> HomeViewModel {
        HomeViewModel(
            couple: CoupleID(rawValue: UUID()),
            partnerName: "Anna",
            quota: quota,
            messageQuota: messageQuota,
            sendMessage: sendMessage,
            loadPartnerName: StubPartnerNameUseCase(),
            navigator: MainNavigator(push: { _ in }, dismiss: {})
        )
    }
}

private extension MessageQuota {
    static func stub(left: Int, cooldownRemaining: TimeInterval, resetRemaining: TimeInterval = 3600) -> MessageQuota {
        MessageQuota(
            dailyLimit: 10,
            messagesLeft: left,
            cooldown: 30,
            cooldownRemaining: cooldownRemaining,
            resetRemaining: resetRemaining
        )
    }
}

private struct StubMessageQuotaUseCase: MessageQuotaUseCase {
    let quota: MessageQuota

    func callAsFunction() async throws -> MessageQuota {
        quota
    }
}

private actor RecordingSendMessageUseCase: SendMessageUseCase {
    private let result: Result<MessageQuota, MessageError>
    private(set) var sentTexts: [String] = []

    init(result: Result<MessageQuota, MessageError> = .success(.stub(left: 6, cooldownRemaining: 30))) {
        self.result = result
    }

    func callAsFunction(_ text: String) async throws -> MessageQuota {
        sentTexts.append(text)
        return try result.get()
    }
}

private struct StubPartnerNameUseCase: PartnerNameUseCase {
    func callAsFunction() async throws -> String {
        "Anna"
    }
}
