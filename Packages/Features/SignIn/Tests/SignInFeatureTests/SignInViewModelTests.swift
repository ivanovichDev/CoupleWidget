import Testing
@testable import SignInFeature

@MainActor
struct SignInViewModelTests {
    @Test func signInReportsSignedIn() {
        var outputs: [SignInOutput] = []
        let navigator = SignInNavigator(push: { _ in }, dismiss: {}, output: { outputs.append($0) })
        let model = SignInViewModel(navigator: navigator)

        model.signIn()

        #expect(outputs == [.signedIn])
    }
}
