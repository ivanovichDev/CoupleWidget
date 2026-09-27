import SwiftUI

public struct PrimaryButton: View {
    @Environment(\.isEnabled) private var isEnabled

    private let title: String
    private let isLoading: Bool
    private let action: () -> Void

    public init(title: String, isLoading: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.isLoading = isLoading
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            ZStack {
                Text(title)
                    .opacity(isLoading ? 0 : 1)
                if isLoading {
                    ProgressView()
                        .tint(Palette.onRose)
                }
            }
            .font(Typography.headline)
            .foregroundStyle(Palette.onRose)
            .frame(maxWidth: .infinity, minHeight: 50)
            .padding(.horizontal, Spacing.space6)
            .background(Palette.roseStrong, in: .capsule)
            .shadow(color: Palette.roseStrong.opacity(0.25), radius: 12, y: 8)
            .opacity(isEnabled ? 1 : 0.45)
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }
}

#Preview {
    VStack(spacing: Spacing.space3) {
        PrimaryButton(title: "Continue") {}
        PrimaryButton(title: "Connect") {}
            .disabled(true)
        PrimaryButton(title: "Continue", isLoading: true) {}
    }
    .padding(Spacing.space4)
    .background(Palette.bg)
}
