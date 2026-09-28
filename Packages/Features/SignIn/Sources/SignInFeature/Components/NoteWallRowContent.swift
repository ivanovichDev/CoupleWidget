import SwiftUI

struct NoteWallRowContent: View {
    static let inset: CGFloat = 32

    let row: NoteWallRow

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array((row.notes + row.notes).enumerated()), id: \.offset) { _, note in
                NoteWallTile(note: note)
                    .padding(.trailing, 14)
            }
        }
        .padding(Self.inset)
    }
}
