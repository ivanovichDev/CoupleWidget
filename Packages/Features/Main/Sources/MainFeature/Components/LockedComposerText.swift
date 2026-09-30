import DesignSystem
import SwiftUI

struct LockedComposerText: View {
    private static let highlightWidth = 0.44
    private static let highlightTravel = 1.165

    let title: String
    let value: String
    let phase: Double
    let isAnimated: Bool

    var body: some View {
        LockedComposerLabel(title: title, value: value)
            .overlay {
                GeometryReader { proxy in
                    LinearGradient(
                        colors: [Palette.roseStrong.opacity(0), Palette.roseStrong, Palette.roseStrong.opacity(0)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: proxy.size.width * Self.highlightWidth)
                    .offset(x: (phase * Self.highlightTravel - Self.highlightWidth / 2) * proxy.size.width)
                }
                .mask {
                    LockedComposerLabel(title: title, value: value)
                }
                .opacity(isAnimated ? 1 : 0)
            }
            .accessibilityElement(children: .combine)
    }
}
