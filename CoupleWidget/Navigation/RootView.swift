import DesignSystem
import MainFeature
import OnboardingFeature
import SignInFeature
import SwiftUI

struct RootView: View {
    let container: AppContainer
    @Bindable var router: AppRouter

    var body: some View {
        NavigationStack(path: $router.path) {
            rootView
                .navigationDestination(for: SignInRoute.self) { route in
                    container.makeSignInFeature().view(for: route, navigator: router.signInNavigator)
                }
                .navigationDestination(for: OnboardingRoute.self) { route in
                    container.makeOnboardingFeature().view(for: route, navigator: router.onboardingNavigator)
                }
                .navigationDestination(for: MainRoute.self) { route in
                    if case .paired(let couple) = router.flow {
                        container.makeMainFeature(couple: couple).view(for: route, navigator: router.mainNavigator)
                    }
                }
        }
        .tint(Palette.roseStrong)
        .preferredColorScheme(.light)
        .animation(.default, value: router.flow)
        .task { router.start() }
    }

    @ViewBuilder
    private var rootView: some View {
        switch router.flow {
        case .launching:
            Color.clear
                .overlay { Image("AppSplachScreen") }
                .clipped()
                .ignoresSafeArea()
        case .signedOut:
            container.makeSignInFeature().view(for: .signIn, navigator: router.signInNavigator)
        case .unpaired:
            container.makeOnboardingFeature().view(for: .name, navigator: router.onboardingNavigator)
        case .paired(let couple):
            container.makeMainFeature(couple: couple).view(for: .home, navigator: router.mainNavigator)
        }
    }
}
