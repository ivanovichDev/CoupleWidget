import DesignSystem
import MainFeature
import OnboardingFeature
import SignInFeature
import SwiftUI
import WidgetKit

@main
struct CoupleWidgetApp: App {
    @Environment(\.scenePhase)
    private var scenePhase
    @State private var router: AppRouter
    private let container: AppContainer

    init() {
        let container = AppContainer(configuration: .current)
        self.container = container
        _router = State(initialValue: AppRouter(
            sessionState: container.sessionState,
            partnerName: container.partnerName,
            messageQuota: container.messageQuota
        ))
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
                    case .home(let session):
                        container.makeMainFeature(session: session).view(for: .home, navigator: router.mainNavigator)
                    }
                }
                .navigationDestination(for: SignInRoute.self) { route in
                    container.makeSignInFeature().view(for: route, navigator: router.signInNavigator)
                }
                .navigationDestination(for: OnboardingRoute.self) { route in
                    container.makeOnboardingFeature().view(for: route, navigator: router.onboardingNavigator)
                }
                .navigationDestination(for: MainRoute.self) { route in
                    if case .home(let session) = router.rootScreen {
                        container.makeMainFeature(session: session).view(for: route, navigator: router.mainNavigator)
                    }
                }
            }
            .tint(Palette.roseStrong)
            .preferredColorScheme(.light)
            .animation(.default, value: router.rootScreen)
            .task {
                await router.start()
            }
            .onChange(of: scenePhase, initial: true) {
                guard scenePhase == .active else { return }
                WidgetCenter.shared.reloadAllTimelines()
                if case .home = router.rootScreen {
                    Task { await container.widgetRegistrar.register() }
                }
            }
            .task(id: router.rootScreen) {
                if case .home = router.rootScreen {
                    await container.widgetRegistrar.register()
                }
            }
        }
    }
}
