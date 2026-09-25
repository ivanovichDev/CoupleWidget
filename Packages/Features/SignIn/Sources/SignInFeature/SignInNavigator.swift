public struct SignInNavigator {
    public let push: (SignInRoute) -> Void
    public let dismiss: () -> Void
    public let output: (SignInOutput) -> Void

    public init(
        push: @escaping (SignInRoute) -> Void,
        dismiss: @escaping () -> Void,
        output: @escaping (SignInOutput) -> Void
    ) {
        self.push = push
        self.dismiss = dismiss
        self.output = output
    }
}

extension SignInNavigator {
    static let preview = SignInNavigator(push: { _ in }, dismiss: {}, output: { _ in })
}
