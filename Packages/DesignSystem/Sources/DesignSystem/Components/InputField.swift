import SwiftUI

public struct InputField: View {
    private let placeholder: String
    @Binding private var text: String
    private var isFocused: FocusState<Bool>.Binding

    public init(_ placeholder: String, text: Binding<String>, isFocused: FocusState<Bool>.Binding) {
        self.placeholder = placeholder
        _text = text
        self.isFocused = isFocused
    }

    public var body: some View {
        TextField(text: $text, prompt: Text(placeholder).foregroundStyle(Palette.inkMuted)) {
            Text(placeholder)
        }
        .font(Typography.body)
        .foregroundStyle(Palette.ink)
        .tint(Palette.roseStrong)
        .focused(isFocused)
        .padding(.horizontal, 20)
        .frame(height: 56)
        .glass(.field, in: .capsule)
        .contentShape(.capsule)
        .onTapGesture { isFocused.wrappedValue = true }
    }
}

#Preview {
    @Previewable @State var text = ""
    @Previewable @FocusState var isFocused: Bool
    InputField("Your name", text: $text, isFocused: $isFocused)
        .padding(Spacing.space4)
        .background { AppBackground() }
}
