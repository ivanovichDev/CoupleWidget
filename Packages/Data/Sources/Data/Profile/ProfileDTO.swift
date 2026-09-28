import Domain
import Foundation

struct ProfileDTO: Codable {
    let id: UUID
    let name: String?
    let birthDate: String?
    let pairingCode: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case birthDate = "birth_date"
        case pairingCode = "pairing_code"
    }
}

extension ProfileDTO {
    var domain: Profile {
        Profile(
            id: UserID(rawValue: id),
            name: name,
            birthDate: birthDate.flatMap(BirthDate.init(databaseValue:)),
            pairingCode: pairingCode
        )
    }
}
