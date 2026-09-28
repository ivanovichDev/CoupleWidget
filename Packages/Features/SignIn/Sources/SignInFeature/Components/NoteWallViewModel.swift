import Observation
import SwiftUI

@Observable
final class NoteWallViewModel {
    private(set) var images: [Image] = []
    private(set) var isRunning = false

    func render(scale: CGFloat, reduceMotion: Bool) {
        guard images.isEmpty else { return }
        images = NoteWallRow.all.compactMap { row in
            let renderer = ImageRenderer(content: NoteWallRowContent(row: row))
            renderer.scale = scale
            return renderer.cgImage.map { Image(decorative: $0, scale: scale) }
        }
        guard !reduceMotion else { return }
        Task { isRunning = true }
    }
}
