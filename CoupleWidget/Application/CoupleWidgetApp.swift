import DesignSystem
import MainFeature
import OnboardingFeature
import SignInFeature
import SwiftUI

@main
struct CoupleWidgetApp: App {
    @State private var router: AppRouter
    private let container: AppContainer

    init() {
        let container = AppContainer(configuration: .current)
        self.container = container
        _router = State(initialValue: AppRouter(sessionState: container.sessionState))
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path) {
                Group {
                    switch router.rootScreen {
                    case .splash:
                        Color.clear
                            .overlay { Image("AppSplachScreen") }
                            .clipped()
                            .ignoresSafeArea()
                    case .signIn:
                        container.makeSignInFeature().view(for: .signIn, navigator: router.signInNavigator)
                    case .onboarding(let route):
                        container.makeOnboardingFeature().view(for: route, navigator: router.onboardingNavigator)
                    case .home(let couple):
                        container.makeMainFeature(couple: couple).view(for: .home, navigator: router.mainNavigator)
                    }
                }
                .navigationDestination(for: SignInRoute.self) { route in
                    container.makeSignInFeature().view(for: route, navigator: router.signInNavigator)
                }
                .navigationDestination(for: OnboardingRoute.self) { route in
                    container.makeOnboardingFeature().view(for: route, navigator: router.onboardingNavigator)
                }
                .navigationDestination(for: MainRoute.self) { route in
                    if case .home(let couple) = router.rootScreen {
                        container.makeMainFeature(couple: couple).view(for: route, navigator: router.mainNavigator)
                    }
                }
            }
            .tint(Palette.roseStrong)
            .preferredColorScheme(.light)
            .animation(.default, value: router.rootScreen)
            .task { await router.start() }
        }
    }
}
