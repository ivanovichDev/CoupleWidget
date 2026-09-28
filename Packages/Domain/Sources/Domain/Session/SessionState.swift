public enum SessionState: Equatable, Sendable {
    case signedOut
    case profileIncomplete
    case unpaired(Profile)
    case paired(CoupleID)
}
