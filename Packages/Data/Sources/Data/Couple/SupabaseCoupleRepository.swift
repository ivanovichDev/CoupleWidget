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
        } catch let error as PostgrestError {
            throw CoupleError(joinError: error) ?? CommonError(error)
        } catch {
            throw CommonError(error)
        }
    }

    public func currentCouple() async throws -> CoupleID? {
        do {
            let userID = try await client.auth.session.user.id
            let members: [CoupleMemberDTO] = try await client
                .from("couple_members")
                .select("couple_id")
                .eq("user_id", value: userID)
                .limit(1)
                .execute()
                .value
            return members.first.map { CoupleID(rawValue: $0.coupleId) }
        } catch {
            throw CommonError(error)
        }
    }

    public func partnerName() async throws -> String {
        do {
            let name: String = try await client
                .rpc("partner_name")
                .execute()
                .value
            return name
        } catch {
            throw CommonError(error)
        }
    }
}
