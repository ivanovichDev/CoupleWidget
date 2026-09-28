public enum SessionState: Equatable, Sendable {
    case signedOut
    case profileIncomplete
    case profileComplete(Profile)
}
