import DesignSystem
import SwiftUI

struct QuickNotes: View {
    let notes: [QuickNote]
    let selected: String
    let pick: (QuickNote) -> Void

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: Spacing.space2) {
                ForEach(notes) { note in
                    QuickNoteChip(title: note.text, isSelected: note.text == selected) {
                        pick(note)
                    }
                }
            }
            .padding(.bottom, 10)
        }
        .contentMargins(.horizontal, Spacing.space4, for: .scrollContent)
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
        .accessibilityLabel(String(localized: "Quick notes"))
    }
}
