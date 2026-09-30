public protocol PartnerNameUseCase: Sendable {
    func callAsFunction() async throws -> String
}

public struct AppPartnerNameUseCase: PartnerNameUseCase {
    private let repository: CoupleRepository

    public init(repository: CoupleRepository) {
        self.repository = repository
    }

    public func callAsFunction() async throws -> String {
        try await repository.partnerName()
    }
}
