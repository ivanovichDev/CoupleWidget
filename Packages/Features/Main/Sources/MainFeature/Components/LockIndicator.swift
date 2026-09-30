import DesignSystem
import SwiftUI

struct LockIndicator: View {
    let countdown: DateInterval?

    var body: some View {
        ZStack {
            Circle()
                .fill(.white.opacity(0.75))
            Circle()
                .strokeBorder(.white.opacity(0.95), lineWidth: 1)
            if let countdown {
                LockCountdownRing(countdown: countdown)
                    .id(countdown)
            }
            Image(systemName: "lock")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Palette.roseStrong)
        }
        .frame(width: 44, height: 44)
        .shadow(color: Palette.roseStrong.opacity(0.12), radius: 6, y: 4)
        .accessibilityElement()
        .accessibilityLabel(String(localized: "Sending is locked"))
    }
}
