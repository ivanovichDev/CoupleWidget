import DesignSystem
import SwiftUI

struct CodeField: View {
    let placeholder: String
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding

    var body: some View {
        TextField(text: $text, prompt: prompt) {
            Text(placeholder)
        }
        .font(.system(size: 24, weight: .bold, design: .rounded))
        .tracking(text.isEmpty ? 0 : 6)
        .multilineTextAlignment(.center)
        .foregroundStyle(Palette.ink)
        .tint(Palette.roseStrong)
        .textInputAutocapitalization(.characters)
        .autocorrectionDisabled()
        .textContentType(.oneTimeCode)
        .focused(isFocused)
        .padding(.horizontal, 20)
        .frame(height: 56)
        .background {
            ZStack {
                Capsule().fill(.white.opacity(0.7))
                Capsule().strokeBorder(.white.opacity(0.95), lineWidth: 1)
            }
        }
        .contentShape(.capsule)
        .onTapGesture { isFocused.wrappedValue = true }
    }

    private var prompt: Text {
        Text(placeholder)
            .font(Typography.body)
            .foregroundStyle(Palette.inkMuted)
    }
}
