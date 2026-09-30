import DesignSystem
import Domain
import Foundation
import Observation

@Observable
final class HomeViewModel {
    static let maxNoteLength = 140

    let quickNotes = [
        QuickNote(text: String(localized: "Good morning, love")),
        QuickNote(text: String(localized: "Miss you")),
        QuickNote(text: String(localized: "Thinking of you")),
        QuickNote(text: String(localized: "On my way home")),
        QuickNote(text: String(localized: "Proud of you")),
        QuickNote(text: String(localized: "Coffee later?")),
        QuickNote(text: String(localized: "Sweet dreams"))
    ]

    let couple: CoupleID
    var draft = ""
    var isComposerFocused = false
    var selectedWidget: WidgetSize? = .small
    var errorMessage: String?
    private(set) var partnerName: String
    private(set) var quota: MessageQuota?
    private(set) var now = Date.now

    private var cooldownEnd: Date?
    private var sendingStartedAt: Date?
    private var resetEnd: Date?
    private let messageQuota: MessageQuotaUseCase
    private let sendMessage: SendMessageUseCase
    private let loadPartnerName: PartnerNameUseCase
    private let navigator: MainNavigator

    init(
        couple: CoupleID,
        partnerName: String?,
        quota: MessageQuota?,
        messageQuota: MessageQuotaUseCase,
        sendMessage: SendMessageUseCase,
        loadPartnerName: PartnerNameUseCase,
        navigator: MainNavigator
    ) {
        self.couple = couple
        self.partnerName = partnerName ?? ""
        self.messageQuota = messageQuota
        self.sendMessage = sendMessage
        self.loadPartnerName = loadPartnerName
        self.navigator = navigator
        if let quota {
            apply(quota)
        }
    }

    var trimmedDraft: String {
        draft.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var canSend: Bool {
        !trimmedDraft.isEmpty && composerLock == nil
    }

    var isLimitReached: Bool {
        quota?.messagesLeft == 0
    }

    var notesLeft: String? {
        guard let quota else { return nil }
        guard let dailyLimit = quota.dailyLimit, let messagesLeft = quota.messagesLeft else { return "∞" }
        return "\(messagesLeft)/\(dailyLimit)"
    }

    var notesLeftAccessibilityLabel: String {
        guard let dailyLimit = quota?.dailyLimit, let messagesLeft = quota?.messagesLeft else {
            return String(localized: "Unlimited notes")
        }
        return String(localized: "\(messagesLeft) of \(dailyLimit) notes left today")
    }

    var composerLock: ComposerLock? {
        if isLimitReached, let resetEnd {
            return ComposerLock(
                title: String(localized: "Limits reset in"),
                value: Self.hoursMinutesSeconds(resetEnd.timeIntervalSince(now)),
                countdown: nil
            )
        }
        guard let cooldown = quota?.cooldown, cooldown > 0 else { return nil }
        let end = sendingStartedAt?.addingTimeInterval(cooldown) ?? cooldownEnd ?? now
        let remaining = end.timeIntervalSince(now)
        guard remaining > 0 else { return nil }
        return ComposerLock(
            title: String(localized: "Next note in"),
            value: Self.minutesSeconds(remaining),
            countdown: DateInterval(start: end.addingTimeInterval(-cooldown), end: end)
        )
    }

    func pickQuickNote(_ note: QuickNote) {
        draft = note.text
    }

    func limitDraft() {
        if draft.count > Self.maxNoteLength {
            draft = String(draft.prefix(Self.maxNoteLength))
        }
    }

    func removeLineBreaks() -> Bool {
        guard draft.contains(where: \.isNewline) else { return false }
        draft.removeAll(where: \.isNewline)
        return true
    }

    func run() async {
        await loadMissingData()
        while !Task.isCancelled {
            now = .now
            if let resetEnd, now >= resetEnd {
                self.resetEnd = nil
                await reloadQuota()
            }
            try? await Task.sleep(for: .seconds(1))
        }
    }

    func send() async {
        isComposerFocused = false
        let text = trimmedDraft
        guard !text.isEmpty, composerLock == nil else { return }
        draft = ""
        sendingStartedAt = .now
        do {
            let quota = try await sendMessage(text)
            sendingStartedAt = nil
            apply(quota)
        } catch {
            sendingStartedAt = nil
            draft = text
            errorMessage = Self.message(for: error)
            await reloadQuota()
        }
    }

    private func loadMissingData() async {
        if partnerName.isEmpty, let name = try? await loadPartnerName() {
            partnerName = name
        }
        if quota == nil {
            await reloadQuota()
        }
    }

    private func reloadQuota() async {
        guard let quota = try? await messageQuota() else { return }
        apply(quota)
    }

    private func apply(_ quota: MessageQuota) {
        let receivedAt = Date.now
        self.quota = quota
        now = receivedAt
        cooldownEnd = receivedAt.addingTimeInterval(quota.cooldownRemaining)
        resetEnd = receivedAt.addingTimeInterval(quota.resetRemaining)
    }

    private static func message(for error: any Error) -> String {
        switch error {
        case MessageError.tooSoon:
            String(localized: "Wait a few seconds before sending the next note.")
        case MessageError.dailyLimitReached:
            String(localized: "You have sent all your notes for today.")
        case CommonError.network:
            String(localized: "Check your internet connection and try again.")
        default:
            String(localized: "Something went wrong. Try again.")
        }
    }

    private static func minutesSeconds(_ interval: TimeInterval) -> String {
        let seconds = Int(interval.rounded(.up))
        return String(format: "%d:%02d", seconds / 60, seconds % 60)
    }

    private static func hoursMinutesSeconds(_ interval: TimeInterval) -> String {
        let seconds = max(0, Int(interval.rounded(.up)))
        return String(format: "%02d:%02d:%02d", seconds / 3600, seconds % 3600 / 60, seconds % 60)
    }
}
