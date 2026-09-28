import Domain
import Foundation
import Testing

struct SessionStateUseCaseTests {
    @Test
    func missingSessionIsSignedOut() async throws {
        let useCase = AppSessionStateUseCase(
            sessionRepository: StubSessionRepository(user: nil),
            profileRepository: StubProfileRepository(profile: Self.profile(name: nil, birthDate: nil))
        )

        #expect(try await useCase() == .signedOut)
    }

    @Test
    func profileWithoutDetailsIsIncomplete() async throws {
        let useCase = AppSessionStateUseCase(
            sessionRepository: StubSessionRepository(user: UserID(rawValue: UUID())),
            profileRepository: StubProfileRepository(profile: Self.profile(name: "Alex", birthDate: nil))
        )

        #expect(try await useCase() == .profileIncomplete)
    }

    @Test
    func filledProfileIsComplete() async throws {
        let profile = Self.profile(name: "Alex", birthDate: BirthDate(year: 1996, month: 5, day: 14))
        let useCase = AppSessionStateUseCase(
            sessionRepository: StubSessionRepository(user: profile.id),
            profileRepository: StubProfileRepository(profile: profile)
        )

        #expect(try await useCase() == .profileComplete(profile))
    }

    private static func profile(name: String?, birthDate: BirthDate?) -> Profile {
        Profile(id: UserID(rawValue: UUID()), name: name, birthDate: birthDate, pairingCode: "ABC234")
    }
}

private struct StubSessionRepository: SessionRepository {
    let user: UserID?

    func signInWithApple() async throws -> UserID {
        UserID(rawValue: UUID())
    }

    func currentUser() async -> UserID? {
        user
    }
}

private struct StubProfileRepository: ProfileRepository {
    let profile: Profile

    func currentProfile() async throws -> Profile {
        profile
    }

    func updateProfile(name: String, birthDate: BirthDate) async throws -> Profile {
        profile
    }
}
