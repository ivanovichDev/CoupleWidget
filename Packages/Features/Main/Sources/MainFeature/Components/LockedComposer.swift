import DesignSystem
import SwiftUI

struct LockedComposer: View {
    let lock: ComposerLock

    @State private var phase = 0.0

    @Environment(\.accessibilityReduceMotion)
    private var reduceMotion

    var body: some View {
        HStack(spacing: Spacing.space3) {
            LockedComposerText(title: lock.title, value: lock.value, phase: phase, isAnimated: !reduceMotion)
                .padding(.vertical, 11)
            LockIndicator(countdown: lock.countdown)
        }
        .padding(.leading, 18)
        .padding([.top, .bottom, .trailing], 6)
        .background {
            LockedComposerGlow(phase: phase)
                .opacity(reduceMotion ? 0 : 1)
                .clipShape(.rect(cornerRadius: 28))
        }
        .glass(.field, in: .rect(cornerRadius: 28))
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 3.6).repeatForever(autoreverses: true)) {
                phase = 1
            }
        }
    }
}

#Preview {
    VStack(spacing: Spacing.space4) {
        LockedComposer(lock: ComposerLock(
            title: "Next note in",
            value: "0:24",
            countdown: DateInterval(start: .now.addingTimeInterval(-6), duration: 30)
        ))
        LockedComposer(lock: ComposerLock(title: "Limits reset in", value: "09:41:07", countdown: nil))
    }
    .padding()
    .background { AppBackground() }
}
