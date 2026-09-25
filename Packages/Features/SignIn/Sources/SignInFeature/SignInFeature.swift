import SwiftUI

public struct SignInFeature {
    public init() {}

    @ViewBuilder
    public func view(for route: SignInRoute, navigator: SignInNavigator) -> some View {
        switch route {
        case .signIn:
            SignInView(model: SignInViewModel(navigator: navigator))
        }
    }
}
