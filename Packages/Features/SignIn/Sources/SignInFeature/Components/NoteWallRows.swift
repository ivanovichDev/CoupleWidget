import SwiftUI

struct NoteWallRows: View {
    let rows: [NoteWallRow]
    let images: [NoteWallRow.ID: Image]
    let isRunning: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(rows) { row in
                if let image = images[row.id] {
                    NoteWallRowView(row: row, image: image, isRunning: isRunning)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
