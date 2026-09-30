import Domain
import Foundation
import Testing
@testable import Data

struct PushTokenMappingTests {
    @Test
    func pushTokenEncodesAsFunctionParameters() throws {
        let dto = PushTokenDTO(PushToken(value: "a1b2", kind: .widget, environment: .sandbox))

        let json = try JSONSerialization.jsonObject(with: JSONEncoder().encode(dto)) as? [String: String]

        #expect(json == ["token": "a1b2", "kind": "widget", "environment": "sandbox"])
    }

    @Test
    func kindsUseDatabaseValues() {
        #expect(PushTokenKind.alert.databaseValue == "alert")
        #expect(PushTokenKind.widget.databaseValue == "widget")
    }

    @Test
    func environmentsUseDatabaseValues() {
        #expect(PushEnvironment.sandbox.databaseValue == "sandbox")
        #expect(PushEnvironment.production.databaseValue == "production")
    }
}
