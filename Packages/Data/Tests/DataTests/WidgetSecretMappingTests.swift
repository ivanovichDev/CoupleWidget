import Domain
import Foundation
import Testing
@testable import Data

struct WidgetSecretMappingTests {
    @Test
    func secretEncodesAsFunctionParameters() throws {
        let dto = WidgetSecretDTO(secret: "a1b2", environment: .sandbox, pushToken: "c3d4")

        let data = try JSONEncoder().encode(dto)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: String]

        #expect(json == ["widget_secret": "a1b2", "environment": "sandbox", "widget_token": "c3d4"])
    }

    @Test
    func missingPushTokenIsOmitted() throws {
        let dto = WidgetSecretDTO(secret: "a1b2", environment: .production, pushToken: nil)

        let data = try JSONEncoder().encode(dto)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: String]

        #expect(json == ["widget_secret": "a1b2", "environment": "production"])
    }

    @Test
    func environmentsUseDatabaseValues() {
        #expect(PushEnvironment.sandbox.databaseValue == "sandbox")
        #expect(PushEnvironment.production.databaseValue == "production")
    }
}
