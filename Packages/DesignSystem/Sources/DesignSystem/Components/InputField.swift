import SwiftUI

public struct InputField: View {
    private let title: String
    @Binding private var text: String
    private var isFocused: FocusState<Bool>.Binding

    public init(_ title: String, text: Binding<String>, isFocused: FocusState<Bool>.Binding) {
        self.title = title
        _text = text
        self.isFocused = isFocused
    }

    public var body: some View {
        TextField(title, text: $text)
            .focused(isFocused)
            .padding(Spacing.medium)
            .background(.fill.tertiary, in: .rect(cornerRadius: CornerRadius.medium))
            .contentShape(.rect)
            .onTapGesture { isFocused.wrappedValue = true }
    }
}

#Preview {
    @Previewable @State var text = ""
    @Previewable @FocusState var isFocused: Bool
    InputField("Name", text: $text, isFocused: $isFocused)
        .padding()
}
