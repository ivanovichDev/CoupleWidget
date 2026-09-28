import SwiftUI

struct ScreenLayoutColumn<Content: View, Input: View, Actions: View>: View {
    let step: Int
    let totalSteps: Int
    let title: String
    let subtitle: String
    let contentSpacing: CGFloat
    let content: Content
    let input: Input
    let actions: Actions

    var body: some View {
        VStack(spacing: 0) {
            StepIndicator(current: step, total: totalSteps)
                .padding(.top, 30)
            ScreenHeader(title: title, subtitle: subtitle)
                .padding(.top, 23)
            content
                .padding(.top, contentSpacing)
            Spacer(minLength: Spacing.space4)
            input
                .liftsAboveKeyboard()
            actions
                .padding(.top, Input.self == EmptyView.self ? 0 : Spacing.space3)
        }
        .padding(.horizontal, Spacing.space4)
    }
}
