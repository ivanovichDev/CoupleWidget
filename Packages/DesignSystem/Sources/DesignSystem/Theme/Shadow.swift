import SwiftUI

extension View {
    public func softShadow() -> some View {
        shadow(color: Palette.roseStrong.opacity(0.10), radius: 12, y: 8)
    }
}
