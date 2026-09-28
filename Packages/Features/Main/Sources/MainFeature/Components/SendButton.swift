import DesignSystem
import SwiftUI

struct SendButton: View {
    let partnerName: String
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.up")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Palette.onRose)
                .frame(width: 44, height: 44)
                .background(Palette.roseStrong, in: .circle)
                .shadow(color: Palette.roseStrong.opacity(0.25), radius: 12, y: 8)
                .opacity(isEnabled ? 1 : 0.45)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityLabel(String(localized: "Send to \(partnerName)'s widget"))
    }
}
