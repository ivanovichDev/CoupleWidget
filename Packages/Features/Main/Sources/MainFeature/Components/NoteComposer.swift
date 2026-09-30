import DesignSystem
import SwiftUI

struct NoteComposer: View {
    let partnerName: String
    let notesLeft: String?
    let notesLeftAccessibilityText: String
    let isLimitReached: Bool
    let lock: ComposerLock?
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding
    @Binding var lineCount: Int
    let maxLength: Int
    let canSend: Bool
    let send: () -> Void

    var body: some View {
        VStack(spacing: Spacing.space2) {
            HStack {
                HStack(spacing: Spacing.space2) {
                    if let notesLeft {
                        NotesLeftBadge(
                            text: notesLeft,
                            isExhausted: isLimitReached,
                            accessibilityText: notesLeftAccessibilityText
                        )
                    }
                    Text(String(localized: "Note for \(partnerName)"))
                }
                Spacer()
                Text("\(text.count) / \(maxLength)")
                    .monospacedDigit()
                    .opacity(lock == nil ? 1 : 0)
            }
            .font(Typography.footnote)
            .foregroundStyle(Palette.inkMuted)
            .padding(.leading, 10)
            .padding(.trailing, Spacing.space4)
            if let lock {
                LockedComposer(lock: lock)
            } else {
                NoteComposerField(
                    partnerName: partnerName,
                    text: $text,
                    isFocused: isFocused,
                    lineCount: $lineCount,
                    canSend: canSend,
                    send: send
                )
            }
        }
    }
}
