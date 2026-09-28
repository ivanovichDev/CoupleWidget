import Domain

enum RootScreen: Equatable {
    case splash
    case signIn
    case onboarding
    case home(CoupleID)
}
