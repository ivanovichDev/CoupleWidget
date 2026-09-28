import SwiftUI

struct NoteWallStrip: View {
    let notes: [NoteWallNote]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(notes) { note in
                NoteWallTile(note: note)
                    .padding(.trailing, 14)
            }
        }
    }
}
