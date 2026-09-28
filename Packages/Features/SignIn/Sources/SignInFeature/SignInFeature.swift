import Domain
import SwiftUI

public struct SignInFeature {
    private let signInWithApple: SignInWithAppleUseCase

    public init(signInWithApple: SignInWithAppleUseCase) {
        self.signInWithApple = signInWithApple
    }

    @ViewBuilder
    public func view(for route: SignInRoute, navigator: SignInNavigator) -> some View {
        switch route {
        case .signIn:
            SignInView(model: SignInViewModel(signInWithApple: signInWithApple, navigator: navigator))
        }
    }
}
