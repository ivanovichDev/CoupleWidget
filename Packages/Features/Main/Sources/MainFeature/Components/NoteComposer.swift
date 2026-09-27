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
                .onGeometryChange(for: Int.self, of: { max(1, Int(($0.size.height / 22).rounded())) }) { lineCount = $0 }
                .padding(.vertical, 11)
                SendButton(partnerName: partnerName, isEnabled: canSend, action: send)
            }
            .padding(.leading, 18)
            .padding([.top, .bottom, .trailing], 6)
            .glass(.field, in: .rect(cornerRadius: 28))
        }
    }
}

private struct SendButton: View {
    let partnerName: String
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.up")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Palette.onRose)
                .frame(width: 44, height: 44)
                .background(Palette.roseStrong, in: .circle)
                .shadow(color: Palette.roseStrong.opacity(0.25), radius: 12, y: 8)
                .opacity(isEnabled ? 1 : 0.45)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityLabel(String(localized: "Send to \(partnerName)'s widget"))
    }
}
