import Foundation
import Observation

@Observable
final class NameViewModel {
    static let maxLength = 24

    var name = "" {
        didSet {
            if name.count > Self.maxLength {
                name = String(name.prefix(Self.maxLength))
            }
        }
    }

    var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var canSubmit: Bool {
        !trimmedName.isEmpty
    }

    private let navigator: OnboardingNavigator

    init(navigator: OnboardingNavigator) {
        self.navigator = navigator
    }

    func submit() {
        guard canSubmit else { return }
        navigator.push(.birthday(name: trimmedName))
    }
}
