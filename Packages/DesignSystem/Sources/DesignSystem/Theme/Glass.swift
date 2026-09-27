import SwiftUI

public struct GlassStyle: Sendable {
    let fillOpacity: Double
    let borderOpacity: Double
    let hasShadow: Bool

    public static let card = GlassStyle(fillOpacity: 0.45, borderOpacity: 0.9, hasShadow: true)
    public static let field = GlassStyle(fillOpacity: 0.55, borderOpacity: 0.85, hasShadow: true)
    public static let control = GlassStyle(fillOpacity: 0.7, borderOpacity: 0.95, hasShadow: false)
}

extension View {
    public func glass(_ style: GlassStyle, in shape: some InsettableShape, blursBackdrop: Bool = true) -> some View {
        background {
            ZStack {
                if blursBackdrop {
                    shape.fill(.ultraThinMaterial)
                }
                shape.fill(.white.opacity(style.fillOpacity))
                shape.strokeBorder(.white.opacity(style.borderOpacity), lineWidth: 1)
            }
            .shadow(color: Palette.roseStrong.opacity(style.hasShadow ? 0.10 : 0), radius: 12, y: 8)
        }
    }
}
