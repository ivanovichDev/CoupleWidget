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

    func send() {
        isComposerFocused = false
        guard canSend else { return }
        draft = ""
    }
}
