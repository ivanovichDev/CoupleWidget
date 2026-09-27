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

private struct QuickNoteChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Typography.subheadline.weight(.semibold))
                .foregroundStyle(isSelected ? Palette.onRose : Palette.ink)
                .lineLimit(1)
                .padding(.horizontal, 14)
                .frame(height: 36)
                .background {
                    ZStack {
                        Capsule().fill(.ultraThinMaterial)
                        Capsule().fill(isSelected ? Palette.roseStrong : .white.opacity(0.6))
                        Capsule().strokeBorder(.white.opacity(0.9), lineWidth: 1)
                    }
                    .shadow(color: Palette.roseStrong.opacity(0.08), radius: 6, y: 4)
                }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
