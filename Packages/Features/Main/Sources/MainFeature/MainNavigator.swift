public struct MainNavigator {
    public let push: (MainRoute) -> Void
    public let dismiss: () -> Void

    public init(push: @escaping (MainRoute) -> Void, dismiss: @escaping () -> Void) {
        self.push = push
        self.dismiss = dismiss
    }
}

extension MainNavigator {
    static let preview = MainNavigator(push: { _ in }, dismiss: {})
}
