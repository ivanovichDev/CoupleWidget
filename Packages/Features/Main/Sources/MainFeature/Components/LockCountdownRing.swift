import DesignSystem
import SwiftUI

struct LockCountdownRing: View {
    let countdown: DateInterval

    @State private var progress: Double

    init(countdown: DateInterval) {
        self.countdown = countdown
        let remaining = countdown.end.timeIntervalSinceNow
        _progress = State(initialValue: min(1, max(0, remaining / countdown.duration)))
    }

    var body: some View {
        ZStack {
            Circle()
                .inset(by: 2)
                .stroke(Palette.roseStrong.opacity(0.15), lineWidth: 2.5)
            Circle()
                .inset(by: 2)
                .trim(from: 0, to: progress)
                .stroke(Palette.roseStrong, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .onAppear {
            withAnimation(.linear(duration: max(0, countdown.end.timeIntervalSinceNow))) {
                progress = 0
            }
        }
    }
}
