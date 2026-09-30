import Domain
import Foundation

struct MessageQuotaDTO: Decodable {
    let dailyLimit: Int?
    let notesLeft: Int?
    let cooldownSeconds: Int
    let cooldownSecondsLeft: Int
    let resetSecondsLeft: Int

    enum CodingKeys: String, CodingKey {
        case dailyLimit = "daily_limit"
        case notesLeft = "notes_left"
        case cooldownSeconds = "cooldown_seconds"
        case cooldownSecondsLeft = "cooldown_seconds_left"
        case resetSecondsLeft = "reset_seconds_left"
    }

    var domain: MessageQuota {
        MessageQuota(
            dailyLimit: dailyLimit,
            messagesLeft: notesLeft,
            cooldown: TimeInterval(cooldownSeconds),
            cooldownRemaining: TimeInterval(cooldownSecondsLeft),
            resetRemaining: TimeInterval(resetSecondsLeft)
        )
    }
}
