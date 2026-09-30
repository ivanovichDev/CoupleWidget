import Domain
import Supabase

public final class SupabaseMessageRepository: MessageRepository {
    private let client: SupabaseClient

    public init(client: SupabaseClient) {
        self.client = client
    }

    public func quota() async throws -> MessageQuota {
        do {
            let quota: MessageQuotaDTO = try await client
                .rpc("note_quota")
                .execute()
                .value
            return quota.domain
        } catch {
            throw CommonError(error)
        }
    }

    public func send(_ text: String) async throws -> MessageQuota {
        do {
            let quota: MessageQuotaDTO = try await client
                .rpc("send_note", params: SendNoteParams(text: text))
                .execute()
                .value
            return quota.domain
        } catch let error as PostgrestError {
            throw MessageError(sendError: error) ?? CommonError(error)
        } catch {
            throw CommonError(error)
        }
    }
}
