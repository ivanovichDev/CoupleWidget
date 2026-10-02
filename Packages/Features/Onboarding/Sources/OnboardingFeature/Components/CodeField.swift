import DesignSystem
import SwiftUI

struct CodeField: View {
    let length: Int
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding

    private var characters: [Character] {
        Array(text)
    }

    var body: some View {
        HStack(spacing: Spacing.space2) {
            ForEach(0..<length, id: \.self) { index in
                CodeCell(
                    character: index < characters.count ? characters[index] : nil,
                    isActive: isFocused.wrappedValue && index == min(characters.count, length - 1)
                )
            }
        }
        .background {
            TextField("", text: $text)
                .textContentType(.oneTimeCode)
                .keyboardType(.asciiCapable)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .focused(isFocused)
                .tint(.clear)
                .foregroundStyle(.clear)
                .opacity(0.011)
                .accessibilityLabel(String(localized: "Partner’s code, \(length) characters"))
        }
        .contentShape(.rect)
        .onTapGesture { isFocused.wrappedValue = true }
    }
}
