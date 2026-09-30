import Domain
import Foundation
import Supabase
import Testing
@testable import Data

struct MessageMappingTests {
    @Test
    func quotaDecodesFromDatabaseResponse() throws {
        let json = Data("""
        {"daily_limit":10,"notes_left":9,"cooldown_seconds":30,"cooldown_seconds_left":24,"reset_seconds_left":36356}
        """.utf8)

        let quota = try JSONDecoder().decode(MessageQuotaDTO.self, from: json).domain

        #expect(quota == MessageQuota(
            dailyLimit: 10,
            messagesLeft: 9,
            cooldown: 30,
            cooldownRemaining: 24,
            resetRemaining: 36356
        ))
    }

    @Test
    func unlimitedQuotaHasNoLimit() throws {
        let json = Data("""
        {"daily_limit":null,"notes_left":null,"cooldown_seconds":30,"cooldown_seconds_left":0,"reset_seconds_left":100}
        """.utf8)

        let quota = try JSONDecoder().decode(MessageQuotaDTO.self, from: json).domain

        #expect(quota.dailyLimit == nil)
        #expect(quota.messagesLeft == nil)
    }

    @Test(arguments: [
        ("note_too_soon", MessageError.tooSoon),
        ("daily_note_limit_reached", MessageError.dailyLimitReached)
    ])
    func knownSendErrorsBecomeMessageErrors(message: String, expected: MessageError) {
        #expect(MessageError(sendError: PostgrestError(code: "P0001", message: message)) == expected)
    }

    @Test
    func otherErrorsAreNotMessageErrors() {
        #expect(MessageError(sendError: PostgrestError(code: "42501", message: "permission denied")) == nil)
    }
}
