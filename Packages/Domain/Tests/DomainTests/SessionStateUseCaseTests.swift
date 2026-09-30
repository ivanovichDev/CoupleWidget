import Domain
import Foundation
import Testing

struct SessionStateUseCaseTests {
    @Test
    func missingSessionIsSignedOut() async throws {
        let useCase = makeUseCase(user: nil, profile: Self.profile(name: nil, birthDate: nil), couple: nil)

        #expect(try await useCase() == .signedOut)
    }

    @Test
    func profileWithoutDetailsIsIncomplete() async throws {
        let useCase = makeUseCase(
            user: UserID(rawValue: UUID()),
            profile: Self.profile(name: "Alex", birthDate: nil),
            couple: nil
        )

        #expect(try await useCase() == .profileIncomplete)
    }

    @Test
    func filledProfileWithoutCoupleIsUnpaired() async throws {
        let profile = Self.profile(name: "Alex", birthDate: BirthDate(year: 1996, month: 5, day: 14))
        let useCase = makeUseCase(user: profile.id, profile: profile, couple: nil)

        #expect(try await useCase() == .unpaired(profile))
    }

    @Test
    func filledProfileWithCoupleIsPaired() async throws {
        let profile = Self.profile(name: "Alex", birthDate: BirthDate(year: 1996, month: 5, day: 14))
        let couple = CoupleID(rawValue: UUID())
        let useCase = makeUseCase(user: profile.id, profile: profile, couple: couple)

        #expect(try await useCase() == .paired(couple))
    }

    private func makeUseCase(user: UserID?, profile: Profile, couple: CoupleID?) -> AppSessionStateUseCase {
        AppSessionStateUseCase(
            sessionRepository: StubSessionRepository(user: user),
            profileRepository: StubProfileRepository(profile: profile),
            coupleRepository: StubCoupleRepository(couple: couple)
        )
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

private struct StubCoupleRepository: CoupleRepository {
    let couple: CoupleID?

    func join(inviteCode: String) async throws -> CoupleID {
        CoupleID(rawValue: UUID())
    }

    func currentCouple() async throws -> CoupleID? {
        couple
    }
    func partnerName() async throws -> String {
        "Anna"
    }
}
