import Foundation
import Observation

@Observable
final class BirthdayViewModel {
    var birthday: Date
    let range: ClosedRange<Date>

    private let navigator: OnboardingNavigator

    init(navigator: OnboardingNavigator, now: Date = .now, calendar: Calendar = .current) {
        self.navigator = navigator
        let earliest = calendar.date(from: DateComponents(year: 1940, month: 1, day: 1)) ?? now
        range = earliest...now
        birthday = calendar.date(from: DateComponents(year: 1996, month: 5, day: 14)) ?? now
    }

    func submit() {
        navigator.push(.invite)
    }
}
