public protocol CurrentCoupleUseCase: Sendable {
    func callAsFunction() async throws -> CoupleID?
}

public struct AppCurrentCoupleUseCase: CurrentCoupleUseCase {
    private let repository: CoupleRepository

    public init(repository: CoupleRepository) {
        self.repository = repository
    }

    public func callAsFunction() async throws -> CoupleID? {
        try await repository.currentCouple()
    }
}
