import SwiftUI
import UIKit

private struct KeyboardLift: ViewModifier {
    let spacing: CGFloat

    @State private var bottom: CGFloat = 0
    @State private var keyboardTop: CGFloat = .infinity

    func body(content: Content) -> some View {
        content
            .offset(y: -lift)
            .background {
                Color.clear
                    .onGeometryChange(for: CGFloat.self) { proxy in
                        proxy.frame(in: .global).maxY
                    } action: { maxY in
                        bottom = maxY
                    }
            }
            .onReceive(
                NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
            ) { notification in
                let endFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
                guard let frame = endFrame as? CGRect else { return }
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
