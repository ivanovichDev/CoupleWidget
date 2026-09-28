import Domain
import Foundation
import Supabase

public final class SupabaseProfileRepository: ProfileRepository {
    private let client: SupabaseClient

    public init(client: SupabaseClient) {
        self.client = client
    }

    public func currentProfile() async throws -> Profile {
        do {
            let userID = try await client.auth.session.user.id
            let profile: ProfileDTO = try await client
                .from("profiles")
                .select("id, name, birth_date, pairing_code")
                .eq("id", value: userID)
                .single()
                .execute()
                .value
            return profile.domain
        } catch {
            throw CommonError(error)
        }
    }

    public func updateProfile(name: String, birthDate: BirthDate) async throws -> Profile {
        do {
            let userID = try await client.auth.session.user.id
            let profile: ProfileDTO = try await client
                .from("profiles")
                .update(ProfileUpdateDTO(name: name, birthDate: birthDate.databaseValue))
                .eq("id", value: userID)
                .select("id, name, birth_date, pairing_code")
                .single()
                .execute()
                .value
            return profile.domain
        } catch {
            throw CommonError(error)
        }
    }
}
