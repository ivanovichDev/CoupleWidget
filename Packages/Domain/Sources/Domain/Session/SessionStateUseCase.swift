public protocol SessionStateUseCase: Sendable {
    func callAsFunction() async throws -> SessionState
}

public struct AppSessionStateUseCase: SessionStateUseCase {
    private let sessionRepository: SessionRepository
    private let profileRepository: ProfileRepository
    private let coupleRepository: CoupleRepository

    public init(
        sessionRepository: SessionRepository,
        profileRepository: ProfileRepository,
        coupleRepository: CoupleRepository
    ) {
        self.sessionRepository = sessionRepository
        self.profileRepository = profileRepository
        self.coupleRepository = coupleRepository
    }

    public func callAsFunction() async throws -> SessionState {
        guard await sessionRepository.currentUser() != nil else { return .signedOut }
        let profile = try await profileRepository.currentProfile()
        guard profile.isComplete else { return .profileIncomplete }
        if let couple = try await coupleRepository.currentCouple() {
            return .paired(couple)
        }
        return .unpaired(profile)
    }
}
