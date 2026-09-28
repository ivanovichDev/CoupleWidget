import SwiftUI

struct NoteWallRowContent: View {
    static let inset: CGFloat = 32

    let row: NoteWallRow

    var body: some View {
        HStack(spacing: 0) {
            NoteWallStrip(notes: row.notes)
            NoteWallStrip(notes: row.notes)
        }
        .padding(Self.inset)
    }
}
