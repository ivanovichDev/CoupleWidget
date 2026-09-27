import SwiftUI

public struct AppBackground: View {
    public init() {}

    public var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            ZStack(alignment: .topLeading) {
                Palette.bg
                glow(Palette.peach, center: UnitPoint(x: 0.3, y: 1), radius: CGSize(width: 0.9, height: 0.5), in: size)
                glow(Palette.lavender, center: UnitPoint(x: 1, y: 0.5), radius: CGSize(width: 0.8, height: 0.5), in: size)
                glow(Palette.blush, center: UnitPoint(x: 0.1, y: 0.12), radius: CGSize(width: 0.9, height: 0.55), in: size)
            }
        }
        .ignoresSafeArea()
    }

    private func glow(_ color: Color, center: UnitPoint, radius: CGSize, in size: CGSize) -> some View {
        EllipticalGradient(
            colors: [color, color.opacity(0)],
            center: .center,
            startRadiusFraction: 0,
            endRadiusFraction: 0.35
        )
        .frame(width: radius.width * size.width * 2, height: radius.height * size.height * 2)
        .position(x: center.x * size.width, y: center.y * size.height)
    }
}

#Preview {
    AppBackground()
}
