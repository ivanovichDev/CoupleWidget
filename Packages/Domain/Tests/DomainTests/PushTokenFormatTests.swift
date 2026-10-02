import Domain
import Foundation
import Testing

struct PushTokenFormatTests {
    @Test
    func encodesTokenAsLowercaseHex() {
        let token = Data([0x00, 0x0a, 0xff, 0x10])

        #expect(PushTokenFormat.hexString(from: token) == "000aff10")
    }
}
