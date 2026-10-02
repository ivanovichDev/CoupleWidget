import Foundation
import Observation

@Observable
final class NameViewModel {
    static let maxLength = 24

    var name = "" {
        didSet {
            let normalized = String(name.filter { !$0.isEmojiSymbol }.prefix(Self.maxLength))
            if normalized != name {
                name = normalized
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
