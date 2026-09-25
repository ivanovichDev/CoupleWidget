import Foundation
import Observation

@Observable
final class NameViewModel {
    var name = ""

    var canSubmit: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private let navigator: OnboardingNavigator

    init(navigator: OnboardingNavigator) {
        self.navigator = navigator
    }

    func submit() {
        guard canSubmit else { return }
        navigator.push(.birthday)
    }
}
