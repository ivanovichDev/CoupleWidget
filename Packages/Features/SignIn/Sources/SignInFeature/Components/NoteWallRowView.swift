import SwiftUI

struct NoteWallRowView: View {
    let row: NoteWallRow
    let image: Image
    let isRunning: Bool

    private var start: CGFloat { row.movesLeft ? 0 : -row.loopWidth }
    private var end: CGFloat { row.movesLeft ? -row.loopWidth : 0 }

    var body: some View {
        image
            .offset(
                x: row.left - NoteWallRowContent.inset + (isRunning ? end : start),
                y: row.top - NoteWallRowContent.inset
            )
            .animation(
                isRunning ? .linear(duration: row.duration).repeatForever(autoreverses: false) : nil,
                value: isRunning
            )
    }
}
