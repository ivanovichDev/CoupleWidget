import Data
import Domain
import MainFeature
import OnboardingFeature
import SignInFeature
import Supabase

final class AppContainer {
    let sessionState: SessionStateUseCase

    private let supabase: SupabaseClient
    private let sessionRepository: SessionRepository
    private let profileRepository: ProfileRepository
    private let coupleRepository: CoupleRepository
    private let signInWithApple: SignInWithAppleUseCase
    private let completeProfile: CompleteProfileUseCase
    private let joinCouple: JoinCoupleUseCase

    init(configuration: AppConfiguration) {
        supabase = SupabaseClient(
            supabaseURL: configuration.supabaseURL,
            supabaseKey: configuration.supabaseKey,
            options: SupabaseClientOptions(auth: .init(emitLocalSessionAsInitialSession: true))
        )
        sessionRepository = SupabaseSessionRepository(client: supabase)
        profileRepository = SupabaseProfileRepository(client: supabase)
        coupleRepository = TemporaryCoupleRepository()
        sessionState = AppSessionStateUseCase(
            sessionRepository: sessionRepository,
            profileRepository: profileRepository
        )
        signInWithApple = AppSignInWithAppleUseCase(repository: sessionRepository)
        completeProfile = AppCompleteProfileUseCase(repository: profileRepository)
        joinCouple = AppJoinCoupleUseCase(repository: coupleRepository)
    }

    func makeSignInFeature() -> SignInFeature {
        SignInFeature(signInWithApple: signInWithApple)
    }

    func makeOnboardingFeature() -> OnboardingFeature {
        OnboardingFeature(completeProfile: completeProfile, joinCouple: joinCouple)
    }

    func makeMainFeature(couple: CoupleID) -> MainFeature {
        MainFeature(couple: couple)
    }
}
