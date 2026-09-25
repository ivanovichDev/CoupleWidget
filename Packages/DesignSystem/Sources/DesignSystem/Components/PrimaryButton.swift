import SwiftUI

public struct PrimaryButton: View {
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
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.small)
        }
        .buttonStyle(.glassProminent)
        .disabled(isLoading)
    }
}

#Preview {
    VStack(spacing: Spacing.medium) {
        PrimaryButton(title: "Continue") {}
        PrimaryButton(title: "Continue", isLoading: true) {}
    }
    .padding()
}
