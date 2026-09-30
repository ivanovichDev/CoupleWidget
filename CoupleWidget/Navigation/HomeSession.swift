import Domain

struct HomeSession: Equatable {
    let couple: CoupleID
    let partnerName: String?
    let quota: MessageQuota?
}
