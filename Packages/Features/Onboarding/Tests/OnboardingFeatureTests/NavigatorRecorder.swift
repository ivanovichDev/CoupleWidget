@testable import OnboardingFeature

@MainActor
final class NavigatorRecorder {
    private(set) var routes: [OnboardingRoute] = []
    private(set) var outputs: [OnboardingOutput] = []

    var navigator: OnboardingNavigator {
        OnboardingNavigator(
            push: { self.routes.append($0) },
            dismiss: {},
            output: { self.outputs.append($0) }
        )
    }
}
