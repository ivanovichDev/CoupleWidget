import Domain
import Foundation
import Testing
@testable import MainFeature

@MainActor
struct HomeViewModelTests {
    @Test func blankDraftCannotBeSent() {
        let model = makeModel()
        model.draft = "   \n"

        model.send()

        #expect(!model.canSend)
        #expect(model.draft == "   \n")
    }

    @Test func sendingClearsDraft() {
        let model = makeModel()
        model.draft = "  Miss you  "

        model.send()

        #expect(model.draft.isEmpty)
    }

    @Test func draftIsLimitedToMaxLength() {
        let model = makeModel()
        model.draft = String(repeating: "a", count: 200)

        model.limitDraft()

        #expect(model.draft.count == HomeViewModel.maxNoteLength)
    }

    private func makeModel() -> HomeViewModel {
        HomeViewModel(
            couple: CoupleID(rawValue: UUID()),
            navigator: MainNavigator(push: { _ in }, dismiss: {})
        )
    }
}

@MainActor
struct HomeViewModelLineBreakTests {
    @Test func lineBreaksAreRemovedAndReported() {
        let model = HomeViewModel(couple: CoupleID(rawValue: UUID()), navigator: MainNavigator(push: { _ in }, dismiss: {}))
        model.draft = "Miss you\n"

        #expect(model.removeLineBreaks())
        #expect(model.draft == "Miss you")
    }

    @Test func draftWithoutLineBreaksIsUntouched() {
        let model = HomeViewModel(couple: CoupleID(rawValue: UUID()), navigator: MainNavigator(push: { _ in }, dismiss: {}))
        model.draft = "Miss you"

        #expect(!model.removeLineBreaks())
        #expect(model.draft == "Miss you")
    }
}

@MainActor
struct HomeViewModelQuickNoteTests {
    @Test func pickingQuickNoteReplacesDraft() {
        let model = HomeViewModel(couple: CoupleID(rawValue: UUID()), navigator: MainNavigator(push: { _ in }, dismiss: {}))
        model.draft = "Hello"

        model.pickQuickNote("Miss you")

        #expect(model.draft == "Miss you")
    }
}
