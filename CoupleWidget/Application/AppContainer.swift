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
    private let currentCouple: CurrentCoupleUseCase

    init(configuration: AppConfiguration) {
        supabase = SupabaseClient(
            supabaseURL: configuration.supabaseURL,
            supabaseKey: configuration.supabaseKey,
            options: SupabaseClientOptions(auth: .init(emitLocalSessionAsInitialSession: true))
        )
        sessionRepository = SupabaseSessionRepository(client: supabase)
        profileRepository = SupabaseProfileRepository(client: supabase)
        coupleRepository = SupabaseCoupleRepository(client: supabase)
        sessionState = AppSessionStateUseCase(
            sessionRepository: sessionRepository,
            profileRepository: profileRepository,
            coupleRepository: coupleRepository
        )
        signInWithApple = AppSignInWithAppleUseCase(repository: sessionRepository)
        completeProfile = AppCompleteProfileUseCase(repository: profileRepository)
        joinCouple = AppJoinCoupleUseCase(repository: coupleRepository)
        currentCouple = AppCurrentCoupleUseCase(repository: coupleRepository)
    }

    func makeSignInFeature() -> SignInFeature {
        SignInFeature(signInWithApple: signInWithApple)
    }

    func makeOnboardingFeature() -> OnboardingFeature {
        OnboardingFeature(completeProfile: completeProfile, joinCouple: joinCouple, currentCouple: currentCouple)
    }

    func makeMainFeature(couple: CoupleID) -> MainFeature {
        MainFeature(couple: couple)
    }
}
