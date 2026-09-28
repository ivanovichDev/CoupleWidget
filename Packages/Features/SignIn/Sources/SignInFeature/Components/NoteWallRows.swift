import SwiftUI

struct NoteWallRows: View {
    let indices: Range<Int>
    let images: [Image]
    let isRunning: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            if images.count == NoteWallRow.all.count {
                ForEach(indices, id: \.self) { index in
                    NoteWallRowView(
                        row: NoteWallRow.all[index],
                        image: images[index],
                        duration: NoteWallRow.durations[index % NoteWallRow.durations.count],
                        movesLeft: index.isMultiple(of: 2),
                        isRunning: isRunning
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
