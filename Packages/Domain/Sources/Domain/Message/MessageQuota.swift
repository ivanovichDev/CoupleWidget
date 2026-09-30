import Foundation

public struct MessageQuota: Equatable, Sendable {
    public let dailyLimit: Int?
    public let messagesLeft: Int?
    public let cooldown: TimeInterval
    public let cooldownRemaining: TimeInterval
    public let resetRemaining: TimeInterval

    public init(
        dailyLimit: Int?,
        messagesLeft: Int?,
        cooldown: TimeInterval,
        cooldownRemaining: TimeInterval,
        resetRemaining: TimeInterval
    ) {
        self.dailyLimit = dailyLimit
        self.messagesLeft = messagesLeft
        self.cooldown = cooldown
        self.cooldownRemaining = cooldownRemaining
        self.resetRemaining = resetRemaining
    }
}
