import Domain
import Foundation

struct PartnerNoteRow: Decodable {
    let authorName: String
    let text: String
    let updatedAt: TimeInterval

    enum CodingKeys: String, CodingKey {
        case authorName = "author_name"
        case text
        case updatedAt = "updated_at"
    }
}

extension PartnerNote {
    init(_ row: PartnerNoteRow) {
        self.init(
            authorName: row.authorName,
            text: row.text,
            updatedAt: Date(timeIntervalSince1970: row.updatedAt)
        )
    }
}
