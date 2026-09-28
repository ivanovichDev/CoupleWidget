import Domain
import Foundation
import Observation

@Observable
final class HomeViewModel {
    static let maxNoteLength = 140

    let quickNotes = [
        String(localized: "Good morning, love"),
        String(localized: "Miss you"),
        String(localized: "Thinking of you"),
        String(localized: "On my way home"),
        String(localized: "Proud of you"),
        String(localized: "Coffee later?"),
        String(localized: "Sweet dreams")
    ]

    let couple: CoupleID
    let partnerName = "Anna"
    var draft = ""
    var isComposerFocused = false
    var selectedWidget: WidgetSize? = .small

    var trimmedDraft: String {
        draft.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var canSend: Bool {
        !trimmedDraft.isEmpty
    }

    private let navigator: MainNavigator

    init(couple: CoupleID, navigator: MainNavigator) {
        self.couple = couple
        self.navigator = navigator
    }

    func pickQuickNote(_ note: String) {
        draft = note
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

    func send() {
        isComposerFocused = false
        guard canSend else { return }
        draft = ""
    }
}
