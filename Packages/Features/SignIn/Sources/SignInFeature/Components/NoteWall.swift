import SwiftUI

struct NoteWall: View {
    @State private var images: [Image] = []
    @State private var isRunning = false
    @Environment(\.accessibilityReduceMotion)
    private var reduceMotion
    @Environment(\.displayScale)
    private var displayScale

    private let blurredRows = 3..<NoteWallRow.all.count

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                NoteWallRows(indices: NoteWallRow.all.indices, images: images, isRunning: isRunning)
                ProgressiveBlur(size: proxy.size) {
                    NoteWallRows(indices: blurredRows, images: images, isRunning: isRunning)
                }
            }
        }
        .clipped()
        .ignoresSafeArea()
        .accessibilityHidden(true)
        .onAppear {
            guard images.isEmpty else { return }
            images = NoteWallRenderer.render(scale: displayScale)
            guard !reduceMotion else { return }
            Task { isRunning = true }
        }
    }
}
