import Domain
import Foundation
import Testing
@testable import Data

struct ProfileMappingTests {
    @Test
    func birthDateUsesDatabaseFormat() {
        #expect(BirthDate(year: 996, month: 5, day: 4).databaseValue == "0996-05-04")
        #expect(BirthDate(databaseValue: "1996-05-14") == BirthDate(year: 1996, month: 5, day: 14))
        #expect(BirthDate(databaseValue: "1996-05") == nil)
    }

    @Test
    func profileDecodesFromDatabaseRow() throws {
        let json = Data("""
        {"id":"7BD3F521-E7C1-4855-B3F3-279880ACC5D8","name":"Alex","birth_date":"1996-05-14","pairing_code":"X4NMGG"}
        """.utf8)

        let profile = try JSONDecoder().decode(ProfileDTO.self, from: json).domain

        #expect(profile.name == "Alex")
        #expect(profile.birthDate == BirthDate(year: 1996, month: 5, day: 14))
        #expect(profile.pairingCode == "X4NMGG")
        #expect(profile.isComplete)
    }
}
