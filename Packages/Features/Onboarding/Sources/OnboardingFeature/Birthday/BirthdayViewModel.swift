import Foundation
import Observation

@Observable
final class BirthdayViewModel {
    var birthday: Date
    let range: ClosedRange<Date>

    private let navigator: OnboardingNavigator

    init(navigator: OnboardingNavigator, now: Date = .now, calendar: Calendar = .current) {
        self.navigator = navigator
        let earliest = calendar.date(byAdding: .year, value: -100, to: now) ?? now
        range = earliest...now
        birthday = calendar.date(byAdding: .year, value: -20, to: now) ?? now
    }

    func submit() {
        navigator.push(.invite)
    }
}
