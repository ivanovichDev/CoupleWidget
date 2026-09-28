import Testing
@testable import OnboardingFeature

@MainActor
struct NameViewModelTests {
    @Test
    func blankNameDoesNotContinue() {
        let recorder = NavigatorRecorder()
        let model = NameViewModel(navigator: recorder.navigator)
        model.name = "   "

        model.submit()

        #expect(!model.canSubmit)
        #expect(recorder.routes.isEmpty)
    }

    @Test
    func validNameOpensBirthdayWithTrimmedName() {
        let recorder = NavigatorRecorder()
        let model = NameViewModel(navigator: recorder.navigator)
        model.name = "  Alex Smith "

        model.submit()

        #expect(recorder.routes == [.birthday(name: "Alex Smith")])
    }

    @Test
    func nameIsLimitedToMaxLength() {
        let model = NameViewModel(navigator: NavigatorRecorder().navigator)

        model.name = String(repeating: "a", count: 30)

        #expect(model.name.count == NameViewModel.maxLength)
    }
}
