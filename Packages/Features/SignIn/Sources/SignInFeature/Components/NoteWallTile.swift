import DesignSystem
import SwiftUI

struct NoteWallTile: View {
    let note: NoteWallNote

    var body: some View {
        WidgetCard(padding: 14, blursBackdrop: false) {
            Text(note.text)
                .font(.system(size: note.isSmall ? 14 : 16, weight: .semibold))
                .lineSpacing(note.isSmall ? 4.2 : 4.8)
                .foregroundStyle(Palette.ink)
                .lineLimit(3)
        } footer: {
            NoteAuthorLabel(note.meta, heartSize: 11, spacing: 5)
                .font(.system(size: 11))
        }
        .frame(width: note.width, height: 120)
    }
}
