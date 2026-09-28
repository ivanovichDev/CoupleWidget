public enum CoupleError: Error, Equatable, Sendable {
    case invalidInviteCode
    case ownInviteCode
    case inviteCodeNotFound
    case partnerAlreadyPaired
}
