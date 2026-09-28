import SwiftUI

struct NoteWall: View {
    @State private var images: [NoteWallRow.ID: Image] = [:]
    @State private var isRunning = false
    @Environment(\.accessibilityReduceMotion)
    private var reduceMotion
    @Environment(\.displayScale)
    private var displayScale

    private let blurredRows = Array(NoteWallRow.all.dropFirst(3))

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                NoteWallRows(rows: NoteWallRow.all, images: images, isRunning: isRunning)
                ProgressiveBlur(size: proxy.size) {
                    NoteWallRows(rows: blurredRows, images: images, isRunning: isRunning)
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
