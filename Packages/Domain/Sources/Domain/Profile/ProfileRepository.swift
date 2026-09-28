public protocol ProfileRepository: Sendable {
    func currentProfile() async throws -> Profile
    func updateProfile(name: String, birthDate: BirthDate) async throws -> Profile
}
