import DesignSystem
import SwiftUI

struct ProgressiveBlurLayer<Content: View>: View {
    let size: CGSize
    let regionTop: CGFloat
    let regionHeight: CGFloat
    let blur: CGFloat
    let start: CGFloat
    let end: CGFloat
    @ViewBuilder let content: () -> Content

    var body: some View {
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
                    .init(color: .black, location: end)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: size.width, height: regionHeight)
            .offset(y: regionTop)
        }
    }
}
