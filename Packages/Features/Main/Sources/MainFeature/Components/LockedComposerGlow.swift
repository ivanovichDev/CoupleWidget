import DesignSystem
import SwiftUI

struct LockedComposerGlow: View {
    private static let travel = 0.456

    let phase: Double

    var body: some View {
        GeometryReader { proxy in
            EllipticalGradient(
                stops: [
                    .init(color: Palette.rose.opacity(0.38), location: 0),
                    .init(color: Palette.lavender.opacity(0.30), location: 0.45),
                    .init(color: Palette.lavender.opacity(0), location: 0.72)
                ],
                center: .center,
                startRadiusFraction: 0,
                endRadiusFraction: 1
            )
            .frame(width: proxy.size.width * 0.84, height: proxy.size.height * 2.42)
            .blur(radius: 14)
            .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
            .offset(x: (phase * 2 - 1) * Self.travel * proxy.size.width)
        }
        .allowsHitTesting(false)
    }
}
