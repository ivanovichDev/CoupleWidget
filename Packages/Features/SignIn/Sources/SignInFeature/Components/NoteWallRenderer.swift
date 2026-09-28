import SwiftUI

enum NoteWallRenderer {
    static func render(scale: CGFloat) -> [Image] {
        NoteWallRow.all.compactMap { row in
            let renderer = ImageRenderer(content: NoteWallRowContent(row: row))
            renderer.scale = scale
            return renderer.cgImage.map { Image(decorative: $0, scale: scale) }
        }
    }
}
