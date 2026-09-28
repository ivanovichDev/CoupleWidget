import SwiftUI

enum NoteWallRenderer {
    static func render(scale: CGFloat) -> [NoteWallRow.ID: Image] {
        var images: [NoteWallRow.ID: Image] = [:]
        for row in NoteWallRow.all {
            let renderer = ImageRenderer(content: NoteWallRowContent(row: row))
            renderer.scale = scale
            images[row.id] = renderer.cgImage.map { Image(decorative: $0, scale: scale) }
        }
        return images
    }
}
