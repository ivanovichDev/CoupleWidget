import DesignSystem
import SwiftUI

struct NoteWall: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.displayScale) private var displayScale
    @State private var images: [Image] = []
    @State private var isRunning = false

    private let blurredRows = 3..<NoteWallRow.all.count

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                rows(NoteWallRow.all.indices)
                ProgressiveBlur(size: proxy.size) {
                    rows(blurredRows)
                }
            }
        }
        .clipped()
        .ignoresSafeArea()
        .accessibilityHidden(true)
        .onAppear(perform: render)
    }

    private func rows(_ indices: Range<Int>) -> some View {
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

    private func render() {
        guard images.isEmpty else { return }
        images = NoteWallRow.all.compactMap { row in
            let renderer = ImageRenderer(content: NoteWallRowContent(row: row))
            renderer.scale = displayScale
            return renderer.cgImage.map { Image(decorative: $0, scale: displayScale) }
        }
        guard !reduceMotion else { return }
        Task { isRunning = true }
    }
}

private struct NoteWallRowView: View {
    let row: NoteWallRow
    let image: Image
    let duration: Double
    let movesLeft: Bool
    let isRunning: Bool

    var body: some View {
        image
            .offset(
                x: row.left - NoteWallRowContent.inset + (isRunning ? end : start),
                y: row.top - NoteWallRowContent.inset
            )
            .animation(isRunning ? .linear(duration: duration).repeatForever(autoreverses: false) : nil, value: isRunning)
    }

    private var start: CGFloat { movesLeft ? 0 : -row.loopWidth }
    private var end: CGFloat { movesLeft ? -row.loopWidth : 0 }
}

private struct NoteWallRowContent: View {
    static let inset: CGFloat = 32

    let row: NoteWallRow

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array((row.notes + row.notes).enumerated()), id: \.offset) { _, note in
                NoteWallTile(note: note)
                    .padding(.trailing, 14)
            }
        }
        .padding(Self.inset)
    }
}

private struct NoteWallTile: View {
    let note: NoteWallNote

    var body: some View {
        WidgetCard(padding: 14, blursBackdrop: false) {
            Text(note.text)
                .font(.system(size: note.isSmall ? 14 : 16, weight: .semibold))
                .lineSpacing(note.isSmall ? 4.2 : 4.8)
                .foregroundStyle(Palette.ink)
                .lineLimit(3)
        } footer: {
            NoteAuthorLabel(note.meta, heartSize: 11, spacing: 5)
                .font(.system(size: 11))
        }
        .frame(width: note.width, height: 120)
    }
}

private struct ProgressiveBlur<Content: View>: View {
    let size: CGSize
    @ViewBuilder let content: () -> Content

    private var regionTop: CGFloat { size.height * 444 / 844 }
    private var regionHeight: CGFloat { size.height - regionTop }

    var body: some View {
        ZStack(alignment: .topLeading) {
            layer(blur: 2, from: 0, to: 0.25)
            layer(blur: 6, from: 0.2, to: 0.5)
            layer(blur: 14, from: 0.4, to: 0.7)
            layer(blur: 28, from: 0.6, to: 0.88)
                .saturation(1.4)
            LinearGradient(
                stops: [
                    .init(color: Palette.bg.opacity(0), location: 0.3),
                    .init(color: Palette.bg.opacity(0.35), location: 1),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: size.width, height: regionHeight)
            .offset(y: regionTop)
        }
        .frame(width: size.width, height: size.height, alignment: .topLeading)
        .allowsHitTesting(false)
    }

    private func layer(blur: CGFloat, from start: CGFloat, to end: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            AppBackground()
            content()
        }
        .frame(width: size.width, height: size.height, alignment: .topLeading)
        .blur(radius: blur)
        .mask(alignment: .topLeading) {
            LinearGradient(
                stops: [
                    .init(color: .clear, location: start),
                    .init(color: .black, location: end),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: size.width, height: regionHeight)
            .offset(y: regionTop)
        }
    }
}
