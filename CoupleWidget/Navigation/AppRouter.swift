import MainFeature
import Observation
import OnboardingFeature
import SignInFeature
import SwiftUI

@Observable
final class AppRouter {
    private(set) var rootScreen: RootScreen = .splash
    var path = NavigationPath()

    func start() {
        guard rootScreen == .splash else { return }
        setRootScreen(.signIn)
    }

    func push(_ route: SignInRoute) {
        path.append(route)
    }

    func push(_ route: OnboardingRoute) {
        path.append(route)
    }

    func push(_ route: MainRoute) {
        path.append(route)
    }

    func dismiss() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func handle(_ output: SignInOutput) {
        switch output {
        case .signedIn:
            setRootScreen(.onboarding)
        }
    }

    func handle(_ output: OnboardingOutput) {
        switch output {
        case .paired(let couple):
            setRootScreen(.home(couple))
        }
    }

    var signInNavigator: SignInNavigator {
        SignInNavigator(
            push: { [weak self] in self?.push($0) },
            dismiss: { [weak self] in self?.dismiss() },
            output: { [weak self] in self?.handle($0) }
        )
    }

    var onboardingNavigator: OnboardingNavigator {
        OnboardingNavigator(
            push: { [weak self] in self?.push($0) },
            dismiss: { [weak self] in self?.dismiss() },
            output: { [weak self] in self?.handle($0) }
        )
    }

    var mainNavigator: MainNavigator {
        MainNavigator(
            push: { [weak self] in self?.push($0) },
            dismiss: { [weak self] in self?.dismiss() }
        )
    }

    private func setRootScreen(_ rootScreen: RootScreen) {
        path = NavigationPath()
        self.rootScreen = rootScreen
    }
}
