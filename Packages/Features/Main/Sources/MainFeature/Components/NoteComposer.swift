import DesignSystem
import SwiftUI

struct NoteComposer: View {
    let partnerName: String
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding
    @Binding var lineCount: Int
    let maxLength: Int
    let canSend: Bool
    let send: () -> Void

    var body: some View {
        VStack(spacing: Spacing.space2) {
            HStack {
                Text(String(localized: "Note for \(partnerName)"))
                Spacer()
                Text("\(text.count) / \(maxLength)")
                    .monospacedDigit()
            }
            .font(Typography.footnote)
            .foregroundStyle(Palette.inkMuted)
            .padding(.horizontal, Spacing.space4)
            HStack(alignment: .bottom, spacing: Spacing.space3) {
                TextField(
                    text: $text,
                    prompt: Text(String(localized: "Write something sweet…")).foregroundStyle(Palette.inkMuted),
                    axis: .vertical
                ) {
                    Text(String(localized: "Note for \(partnerName)"))
                }
                .font(Typography.body)
                .foregroundStyle(Palette.ink)
                .tint(Palette.roseStrong)
                .lineLimit(1...4)
                .submitLabel(.done)
                .focused(isFocused)
                .onGeometryChange(for: Int.self) { proxy in
                    max(1, Int((proxy.size.height / 22).rounded()))
                } action: { count in
                    lineCount = count
                }
                .padding(.vertical, 11)
                SendButton(partnerName: partnerName, isEnabled: canSend, action: send)
            }
            .padding(.leading, 18)
            .padding([.top, .bottom, .trailing], 6)
            .glass(.field, in: .rect(cornerRadius: 28))
        }
    }
}
