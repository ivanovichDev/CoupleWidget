import SwiftUI
import UIKit

extension View {
    public func dismissesKeyboardOnTap() -> some View {
        contentShape(.rect)
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
    }
}
