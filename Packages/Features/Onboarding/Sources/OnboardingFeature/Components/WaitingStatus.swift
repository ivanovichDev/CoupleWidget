import DesignSystem
import SwiftUI

struct WaitingStatus: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isPulsing = false

    var body: some View {
        HStack(spacing: Spacing.space2) {
            Circle()
                .fill(Palette.rose)
                .frame(width: 8, height: 8)
                .opacity(reduceMotion ? 1 : (isPulsing ? 1 : 0.35))
                .scaleEffect(reduceMotion ? 1 : (isPulsing ? 1 : 0.85))
                .accessibilityHidden(true)
            Text(String(localized: "Waiting for your partner…"))
                .font(Typography.subheadline)
                .foregroundStyle(Palette.inkMuted)
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}
