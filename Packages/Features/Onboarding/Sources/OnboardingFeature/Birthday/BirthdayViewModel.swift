import Domain
import Foundation
import Observation

@Observable
final class BirthdayViewModel {
    var birthday: Date {
        didSet {
            isBirthdayChosen = true
        }
    }

    let range: ClosedRange<Date>
    private(set) var isBirthdayChosen = false
    private(set) var isSaving = false

    private let name: String
    private let completeProfile: CompleteProfileUseCase
    private let navigator: OnboardingNavigator
    private let calendar: Calendar

    init(
        name: String,
        completeProfile: CompleteProfileUseCase,
        navigator: OnboardingNavigator,
        now: Date = .now,
        calendar: Calendar = .current
    ) {
        self.name = name
        self.completeProfile = completeProfile
        self.navigator = navigator
        self.calendar = calendar
        range = BirthDate.allowedRange(now: now, calendar: calendar)
        let suggested = calendar.date(from: DateComponents(year: 1996, month: 5, day: 14)) ?? range.upperBound
        birthday = min(max(suggested, range.lowerBound), range.upperBound)
    }

    func submit() async {
        guard isBirthdayChosen, !isSaving else { return }
        isSaving = true
        defer { isSaving = false }
        do {
            let birthDate = BirthDate(date: birthday, calendar: calendar)
            let profile = try await completeProfile(name: name, birthDate: birthDate)
            navigator.push(.invite(pairingCode: profile.pairingCode))
        } catch {
            return
        }
    }
}
