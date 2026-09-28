import Foundation

public protocol CompleteProfileUseCase: Sendable {
    func callAsFunction(name: String, birthDate: BirthDate) async throws -> Profile
}

public struct AppCompleteProfileUseCase: CompleteProfileUseCase {
    private let repository: ProfileRepository
    private let calendar: Calendar
    private let now: @Sendable () -> Date

    public init(
        repository: ProfileRepository,
        calendar: Calendar = .current,
        now: @escaping @Sendable () -> Date = { .now }
    ) {
        self.repository = repository
        self.calendar = calendar
        self.now = now
    }

    public func callAsFunction(name: String, birthDate: BirthDate) async throws -> Profile {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw ProfileError.invalidName }
        guard
            let date = birthDate.date(in: calendar),
            BirthDate.allowedRange(now: now(), calendar: calendar).contains(date)
        else { throw ProfileError.invalidBirthDate }
        return try await repository.updateProfile(name: trimmed, birthDate: birthDate)
    }
}
