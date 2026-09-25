import Testing
@testable import OnboardingFeature

@MainActor
struct NameViewModelTests {
    @Test func blankNameDoesNotContinue() {
        let recorder = NavigatorRecorder()
        let model = NameViewModel(navigator: recorder.navigator)
        model.name = "   "

        model.submit()

        #expect(!model.canSubmit)
        #expect(recorder.routes.isEmpty)
    }

    @Test func validNameOpensBirthday() {
        let recorder = NavigatorRecorder()
        let model = NameViewModel(navigator: recorder.navigator)
        model.name = "Alex"

        model.submit()

        #expect(recorder.routes == [.birthday])
    }
}
