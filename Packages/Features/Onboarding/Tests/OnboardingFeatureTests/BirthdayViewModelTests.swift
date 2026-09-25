import Foundation
import Testing
@testable import OnboardingFeature

@MainActor
struct BirthdayViewModelTests {
    @Test func birthdayCannotBeInTheFuture() {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let model = BirthdayViewModel(navigator: NavigatorRecorder().navigator, now: now)

        #expect(model.range.upperBound == now)
        #expect(model.range.contains(model.birthday))
    }

    @Test func submitOpensInvite() {
        let recorder = NavigatorRecorder()
        let model = BirthdayViewModel(navigator: recorder.navigator)

        model.submit()

        #expect(recorder.routes == [.invite])
    }
}
