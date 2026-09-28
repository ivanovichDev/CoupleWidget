import SwiftUI

struct NoteWall: View {
    @Environment(\.accessibilityReduceMotion)
    private var reduceMotion
    @Environment(\.displayScale)
    private var displayScale
    @State private var model = NoteWallViewModel()

    private let blurredRows = 3..<NoteWallRow.all.count

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                NoteWallRows(indices: NoteWallRow.all.indices, images: model.images, isRunning: model.isRunning)
                ProgressiveBlur(size: proxy.size) {
                    NoteWallRows(indices: blurredRows, images: model.images, isRunning: model.isRunning)
                }
            }
        }
        .clipped()
        .ignoresSafeArea()
        .accessibilityHidden(true)
        .onAppear { model.render(scale: displayScale, reduceMotion: reduceMotion) }
    }
}
