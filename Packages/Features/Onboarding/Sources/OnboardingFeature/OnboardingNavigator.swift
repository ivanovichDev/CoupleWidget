public struct OnboardingNavigator {
    public let push: (OnboardingRoute) -> Void
    public let dismiss: () -> Void
    public let output: (OnboardingOutput) -> Void

    public init(
        push: @escaping (OnboardingRoute) -> Void,
        dismiss: @escaping () -> Void,
        output: @escaping (OnboardingOutput) -> Void
    ) {
        self.push = push
        self.dismiss = dismiss
        self.output = output
    }
}

extension OnboardingNavigator {
    static let preview = OnboardingNavigator(push: { _ in }, dismiss: {}, output: { _ in })
}
