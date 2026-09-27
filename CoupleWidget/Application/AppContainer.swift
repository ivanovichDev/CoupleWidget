import Data
import Domain
import MainFeature
import OnboardingFeature
import SignInFeature
import Supabase

final class AppContainer {
    private let supabase: SupabaseClient
    private let coupleRepository: CoupleRepository
    private let joinCouple: JoinCoupleUseCase

    init(configuration: AppConfiguration) {
        supabase = SupabaseClient(
            supabaseURL: configuration.supabaseURL,
            supabaseKey: configuration.supabaseKey
        )
        coupleRepository = TemporaryCoupleRepository()
        joinCouple = AppJoinCoupleUseCase(repository: coupleRepository)
    }

    func makeSignInFeature() -> SignInFeature {
        SignInFeature()
    }

    func makeOnboardingFeature() -> OnboardingFeature {
        OnboardingFeature(joinCouple: joinCouple)
    }

    func makeMainFeature(couple: CoupleID) -> MainFeature {
        MainFeature(couple: couple)
    }
}
