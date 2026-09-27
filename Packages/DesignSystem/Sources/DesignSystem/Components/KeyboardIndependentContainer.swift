import SwiftUI
import UIKit

private struct KeyboardIndependentContainer: UIViewControllerRepresentable {
    let content: AnyView

    func makeUIViewController(context: Context) -> UIHostingController<AnyView> {
        let controller = UIHostingController(rootView: content)
        controller.safeAreaRegions = .container
        controller.view.backgroundColor = .clear
        return controller
    }

    func updateUIViewController(_ controller: UIHostingController<AnyView>, context: Context) {
        controller.rootView = content
    }
}

extension View {
    public func ignoresKeyboardLayout() -> some View {
        KeyboardIndependentContainer(content: AnyView(self))
    }
}
