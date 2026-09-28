import Domain
import Observation

@Observable
final class SignInViewModel {
    private(set) var isSigningIn = false

    private let signInWithApple: SignInWithAppleUseCase
    private let navigator: SignInNavigator

    init(signInWithApple: SignInWithAppleUseCase, navigator: SignInNavigator) {
        self.signInWithApple = signInWithApple
        self.navigator = navigator
    }

    func signIn() async {
        guard !isSigningIn else { return }
        isSigningIn = true
        defer { isSigningIn = false }
        do {
            _ = try await signInWithApple()
            navigator.output(.signedIn)
        } catch {
            return
        }
    }
}
