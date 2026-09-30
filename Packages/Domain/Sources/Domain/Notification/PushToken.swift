public struct PushToken: Equatable, Sendable {
    public let value: String
    public let kind: PushTokenKind
    public let environment: PushEnvironment

    public init(value: String, kind: PushTokenKind, environment: PushEnvironment) {
        self.value = value
        self.kind = kind
        self.environment = environment
    }
}
