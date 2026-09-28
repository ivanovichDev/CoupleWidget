import Domain
import OnboardingFeature

enum RootScreen: Equatable {
    case splash
    case signIn
    case onboarding(OnboardingRoute)
    case home(CoupleID)
}
