public protocol SessionStateUseCase: Sendable {
    func callAsFunction() async throws -> SessionState
}

public struct AppSessionStateUseCase: SessionStateUseCase {
    private let sessionRepository: SessionRepository
    private let profileRepository: ProfileRepository

    public init(sessionRepository: SessionRepository, profileRepository: ProfileRepository) {
        self.sessionRepository = sessionRepository
        self.profileRepository = profileRepository
    }

    public func callAsFunction() async throws -> SessionState {
        guard await sessionRepository.currentUser() != nil else { return .signedOut }
        let profile = try await profileRepository.currentProfile()
        return profile.isComplete ? .profileComplete(profile) : .profileIncomplete
    }
}
