import DesignSystem
import SwiftUI

struct QuickNotes: View {
    let notes: [String]
    let selected: String
    let pick: (String) -> Void

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: Spacing.space2) {
                ForEach(notes, id: \.self) { note in
                    QuickNoteChip(title: note, isSelected: note == selected) {
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
