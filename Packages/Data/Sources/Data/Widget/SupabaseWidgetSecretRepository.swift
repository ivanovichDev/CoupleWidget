import Domain
import Supabase

public final class SupabaseWidgetSecretRepository: WidgetSecretRepository {
    private let client: SupabaseClient

    public init(client: SupabaseClient) {
        self.client = client
    }

    public func register(secret: String, environment: PushEnvironment, pushToken: String?) async throws {
        do {
            try await client
                .rpc(
                    "register_widget_secret",
                    params: WidgetSecretDTO(secret: secret, environment: environment, pushToken: pushToken)
                )
                .execute()
        } catch {
            throw CommonError(error)
        }
    }
}
