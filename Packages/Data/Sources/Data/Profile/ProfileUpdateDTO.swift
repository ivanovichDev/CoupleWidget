struct ProfileUpdateDTO: Encodable {
    let name: String
    let birthDate: String

    enum CodingKeys: String, CodingKey {
        case name
        case birthDate = "birth_date"
    }
}
