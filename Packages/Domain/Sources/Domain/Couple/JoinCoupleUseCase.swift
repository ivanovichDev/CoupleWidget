import Foundation

public protocol JoinCoupleUseCase: Sendable {
    func callAsFunction(inviteCode: String) async throws -> CoupleID
}

public struct AppJoinCoupleUseCase: JoinCoupleUseCase {
    private let repository: CoupleRepository

    public init(repository: CoupleRepository) {
        self.repository = repository
    }

    public func callAsFunction(inviteCode: String) async throws -> CoupleID {
        let trimmed = inviteCode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw CoupleError.invalidInviteCode }
        return try await repository.join(inviteCode: trimmed)
    }
}
