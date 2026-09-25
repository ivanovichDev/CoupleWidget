import Domain
import Foundation
import Supabase

public final class SupabaseCoupleRepository: CoupleRepository {
    private let client: SupabaseClient

    public init(client: SupabaseClient) {
        self.client = client
    }

    public func join(inviteCode: String) async throws -> CoupleID {
        do {
            let id: UUID = try await client
                .rpc("join_couple", params: ["invite_code": inviteCode])
                .execute()
                .value
            return CoupleID(rawValue: id)
        } catch {
            throw CommonError(error)
        }
    }
}
