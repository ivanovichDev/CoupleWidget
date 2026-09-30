import Domain
import Supabase

public final class SupabasePushTokenRepository: PushTokenRepository {
    private let client: SupabaseClient

    public init(client: SupabaseClient) {
        self.client = client
    }

    public func register(_ token: PushToken) async throws {
        do {
            try await client
                .rpc("register_push_token", params: PushTokenDTO(token))
                .execute()
        } catch {
            throw CommonError(error)
        }
    }
}
