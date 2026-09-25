import Domain

enum AppFlow: Equatable {
    case launching
    case signedOut
    case unpaired
    case paired(CoupleID)
}
