import Domain
import Foundation
import Testing

struct CompleteProfileUseCaseTests {
    private static let calendar = Calendar(identifier: .gregorian)
    private static let now = calendar.date(from: DateComponents(year: 2026, month: 9, day: 28, hour: 12)) ?? .now

    @Test
    func trimsNameBeforeSaving() async throws {
        let repository = RecordingProfileRepository()
        let useCase = makeUseCase(repository: repository)

        _ = try await useCase(name: "  Alex \n", birthDate: BirthDate(year: 1996, month: 5, day: 14))

        #expect(await repository.receivedNames == ["Alex"])
    }

    @Test
    func rejectsBlankName() async {
        let useCase = makeUseCase(repository: RecordingProfileRepository())

        await #expect(throws: ProfileError.invalidName) {
            try await useCase(name: "   ", birthDate: BirthDate(year: 1996, month: 5, day: 14))
        }
    }

    @Test(arguments: [
        BirthDate(year: 2013, month: 9, day: 28),
        BirthDate(year: 1876, month: 9, day: 28)
    ])
    func acceptsBoundaryAges(birthDate: BirthDate) async throws {
        let useCase = makeUseCase(repository: RecordingProfileRepository())

        _ = try await useCase(name: "Alex", birthDate: birthDate)
    }

    @Test(arguments: [
        BirthDate(year: 2013, month: 9, day: 29),
        BirthDate(year: 1876, month: 9, day: 27),
        BirthDate(year: 1996, month: 2, day: 30)
    ])
    func rejectsInvalidBirthDates(birthDate: BirthDate) async {
        let useCase = makeUseCase(repository: RecordingProfileRepository())

        await #expect(throws: ProfileError.invalidBirthDate) {
            try await useCase(name: "Alex", birthDate: birthDate)
        }
    }

    private func makeUseCase(repository: RecordingProfileRepository) -> AppCompleteProfileUseCase {
        AppCompleteProfileUseCase(repository: repository, calendar: Self.calendar) { Self.now }
    }
}

private actor RecordingProfileRepository: ProfileRepository {
    private(set) var receivedNames: [String] = []

    func currentProfile() async throws -> Profile {
        Profile(id: UserID(rawValue: UUID()), name: nil, birthDate: nil, pairingCode: "ABC234")
    }

    func updateProfile(name: String, birthDate: BirthDate) async throws -> Profile {
        receivedNames.append(name)
        return Profile(id: UserID(rawValue: UUID()), name: name, birthDate: birthDate, pairingCode: "ABC234")
    }
}
