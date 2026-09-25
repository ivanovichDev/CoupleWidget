import Observation

@Observable
final class SignInViewModel {
    private let navigator: SignInNavigator

    init(navigator: SignInNavigator) {
        self.navigator = navigator
    }

    func signIn() {
        navigator.output(.signedIn)
    }
}
