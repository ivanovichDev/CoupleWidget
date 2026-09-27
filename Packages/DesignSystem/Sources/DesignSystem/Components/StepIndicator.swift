import SwiftUI

public struct StepIndicator: View {
    private let current: Int
    private let total: Int

    public init(current: Int, total: Int) {
        self.current = current
        self.total = total
    }

    public var body: some View {
        HStack(spacing: 6) {
            ForEach(1...total, id: \.self) { step in
                Capsule()
                    .fill(step <= current ? Palette.roseStrong : Palette.rose.opacity(0.25))
                    .frame(height: 6)
            }
        }
        .frame(width: 238)
        .accessibilityElement()
        .accessibilityLabel(String(localized: "Step \(current) of \(total)", bundle: .module))
    }
}

#Preview {
    VStack(spacing: Spacing.space4) {
        StepIndicator(current: 1, total: 3)
        StepIndicator(current: 2, total: 3)
        StepIndicator(current: 3, total: 3)
    }
    .padding()
}
