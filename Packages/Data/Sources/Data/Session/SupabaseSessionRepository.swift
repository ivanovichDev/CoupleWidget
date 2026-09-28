import AuthenticationServices
import Domain
import Foundation
import Supabase

public final class SupabaseSessionRepository: SessionRepository {
    private let client: SupabaseClient

    public init(client: SupabaseClient) {
        self.client = client
    }

    public func signInWithApple() async throws -> UserID {
        let token: AppleIDToken
        do {
            token = try await AppleIDAuthorization().authorize()
        } catch let error as ASAuthorizationError where error.code == .canceled {
            throw SessionError.canceled
        } catch {
            throw CommonError(error)
        }
        do {
            let session = try await client.auth.signInWithIdToken(
                credentials: OpenIDConnectCredentials(provider: .apple, idToken: token.idToken, nonce: token.nonce)
            )
            return UserID(rawValue: session.user.id)
        } catch {
            throw CommonError(error)
        }
    }

    public func currentUser() async -> UserID? {
        client.auth.currentUser.map { UserID(rawValue: $0.id) }
    }
}
