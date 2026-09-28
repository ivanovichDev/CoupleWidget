import Foundation

struct CoupleMemberDTO: Codable {
    let coupleId: UUID

    enum CodingKeys: String, CodingKey {
        case coupleId = "couple_id"
    }
}
