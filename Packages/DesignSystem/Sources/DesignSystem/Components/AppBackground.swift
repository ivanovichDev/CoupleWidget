import SwiftUI

public struct AppBackground: View {
    public init() {}

    public var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            ZStack(alignment: .topLeading) {
                Palette.background
                AppBackgroundGlow(
                    color: Palette.peach,
                    center: UnitPoint(x: 0.3, y: 1),
                    radius: CGSize(width: 0.9, height: 0.5),
                    size: size
                )
                AppBackgroundGlow(
                    color: Palette.lavender,
                    center: UnitPoint(x: 1, y: 0.5),
                    radius: CGSize(width: 0.8, height: 0.5),
                    size: size
                )
                AppBackgroundGlow(
                    color: Palette.blush,
                    center: UnitPoint(x: 0.1, y: 0.12),
                    radius: CGSize(width: 0.9, height: 0.55),
                    size: size
                )
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    AppBackground()
}
