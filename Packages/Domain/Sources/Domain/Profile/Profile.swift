public struct Profile: Identifiable, Equatable, Sendable {
    public let id: UserID
    public let name: String?
    public let birthDate: BirthDate?
    public let pairingCode: String

    public var isComplete: Bool {
        name != nil && birthDate != nil
    }

    public init(id: UserID, name: String?, birthDate: BirthDate?, pairingCode: String) {
        self.id = id
        self.name = name
        self.birthDate = birthDate
        self.pairingCode = pairingCode
    }
}
