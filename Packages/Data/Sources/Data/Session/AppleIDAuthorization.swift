import AuthenticationServices
import CryptoKit
import Domain
import Foundation
import UIKit

@MainActor
final class AppleIDAuthorization: NSObject {
    private var continuation: CheckedContinuation<ASAuthorization, any Error>?

    func authorize() async throws -> AppleIDToken {
        let nonce = Self.makeNonce()
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.nonce = Self.sha256(nonce)
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        let authorization = try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            controller.performRequests()
        }
        guard
            let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let tokenData = credential.identityToken,
            let idToken = String(data: tokenData, encoding: .utf8)
        else { throw CommonError.unknown }
        return AppleIDToken(idToken: idToken, nonce: nonce)
    }

    private func finish(with result: Result<ASAuthorization, any Error>) {
        continuation?.resume(with: result)
        continuation = nil
    }

    private static func makeNonce() -> String {
        var generator = SystemRandomNumberGenerator()
        let bytes = (0..<32).map { _ in UInt8.random(in: .min ... .max, using: &generator) }
        return bytes.map { String(format: "%02x", $0) }.joined()
    }

    private static func sha256(_ value: String) -> String {
        SHA256.hash(data: Data(value.utf8)).map { String(format: "%02x", $0) }.joined()
    }
}

extension AppleIDAuthorization: ASAuthorizationControllerDelegate {
    nonisolated func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        MainActor.assumeIsolated {
            finish(with: .success(authorization))
        }
    }

    nonisolated func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: any Error
    ) {
        MainActor.assumeIsolated {
            finish(with: .failure(error))
        }
    }
}

extension AppleIDAuthorization: ASAuthorizationControllerPresentationContextProviding {
    nonisolated func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        MainActor.assumeIsolated {
            let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
            guard let scene = scenes.first(where: { $0.activationState == .foregroundActive }) ?? scenes.first else {
                fatalError("Sign in with Apple requires a connected window scene")
            }
            return scene.keyWindow ?? ASPresentationAnchor(windowScene: scene)
        }
    }
}
