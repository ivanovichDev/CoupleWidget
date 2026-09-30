public enum MessageError: Error, Equatable, Sendable {
    case empty
    case tooSoon
    case dailyLimitReached
}
