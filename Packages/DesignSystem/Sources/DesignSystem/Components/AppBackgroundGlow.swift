import SwiftUI

struct AppBackgroundGlow: View {
    let color: Color
    let center: UnitPoint
    let radius: CGSize
    let size: CGSize

    var body: some View {
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
