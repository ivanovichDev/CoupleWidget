import SwiftUI

struct NoteWallRowView: View {
    let row: NoteWallRow
    let image: Image
    let duration: Double
    let movesLeft: Bool
    let isRunning: Bool

    private var start: CGFloat { movesLeft ? 0 : -row.loopWidth }
    private var end: CGFloat { movesLeft ? -row.loopWidth : 0 }

    var body: some View {
        image
            .offset(
                x: row.left - NoteWallRowContent.inset + (isRunning ? end : start),
                y: row.top - NoteWallRowContent.inset
            )
            .animation(
                isRunning ? .linear(duration: duration).repeatForever(autoreverses: false) : nil,
                value: isRunning
            )
    }
}
