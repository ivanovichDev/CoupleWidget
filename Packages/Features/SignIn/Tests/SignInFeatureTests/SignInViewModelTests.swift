import Domain
import Foundation
import Testing
@testable import SignInFeature

@MainActor
struct SignInViewModelTests {
    @Test
    func successfulSignInReportsSignedIn() async {
        var outputs: [SignInOutput] = []
        let navigator = SignInNavigator(push: { _ in }, dismiss: {}, output: { outputs.append($0) })
        let model = SignInViewModel(signInWithApple: StubSignInWithAppleUseCase(error: nil), navigator: navigator)

        await model.signIn()

        #expect(outputs == [.signedIn])
        #expect(!model.isSigningIn)
    }

    @Test
    func failedSignInStaysOnScreen() async {
        var outputs: [SignInOutput] = []
        let navigator = SignInNavigator(push: { _ in }, dismiss: {}, output: { outputs.append($0) })
        let model = SignInViewModel(
            signInWithApple: StubSignInWithAppleUseCase(error: SessionError.canceled),
            navigator: navigator
        )

        await model.signIn()

        #expect(outputs.isEmpty)
        #expect(!model.isSigningIn)
    }
}

private struct StubSignInWithAppleUseCase: SignInWithAppleUseCase {
    let error: SessionError?

    func callAsFunction() async throws -> UserID {
        if let error {
            throw error
        }
        return UserID(rawValue: UUID())
    }
}
