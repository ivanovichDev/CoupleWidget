import DesignSystem
import SwiftUI

struct ProgressiveBlur<Content: View>: View {
    let size: CGSize
    @ViewBuilder let content: () -> Content

    private var regionTop: CGFloat { size.height * 444 / 844 }
    private var regionHeight: CGFloat { size.height - regionTop }

    var body: some View {
        ZStack(alignment: .topLeading) {
            ProgressiveBlurLayer(
                size: size,
                regionTop: regionTop,
                regionHeight: regionHeight,
                blur: 2,
                start: 0,
                end: 0.25,
                content: content
            )
            ProgressiveBlurLayer(
                size: size,
                regionTop: regionTop,
                regionHeight: regionHeight,
                blur: 6,
                start: 0.2,
                end: 0.5,
                content: content
            )
            ProgressiveBlurLayer(
                size: size,
                regionTop: regionTop,
                regionHeight: regionHeight,
                blur: 14,
                start: 0.4,
                end: 0.7,
                content: content
            )
            ProgressiveBlurLayer(
                size: size,
                regionTop: regionTop,
                regionHeight: regionHeight,
                blur: 28,
                start: 0.6,
                end: 0.88,
                content: content
            )
                .saturation(1.4)
            LinearGradient(
                stops: [
                    .init(color: Palette.background.opacity(0), location: 0.3),
                    .init(color: Palette.background.opacity(0.35), location: 1)
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
}
