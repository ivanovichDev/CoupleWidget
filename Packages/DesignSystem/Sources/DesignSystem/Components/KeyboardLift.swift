import SwiftUI
import UIKit

private struct KeyboardLift: ViewModifier {
    let spacing: CGFloat

    @State private var bottom: CGFloat = 0
    @State private var keyboardTop: CGFloat = .infinity

    func body(content: Content) -> some View {
        content
            .onGeometryChange(for: CGFloat.self, of: { $0.frame(in: .global).maxY }) { bottom = $0 }
            .offset(y: -lift)
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)) { notification in
                guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                withAnimation(.easeOut(duration: 0.25)) {
                    keyboardTop = frame.minY
                }
            }
    }

    private var lift: CGFloat {
        max(0, bottom - keyboardTop + spacing)
    }
}

extension View {
    public func liftsAboveKeyboard(spacing: CGFloat = Spacing.space3) -> some View {
        modifier(KeyboardLift(spacing: spacing))
    }
}
