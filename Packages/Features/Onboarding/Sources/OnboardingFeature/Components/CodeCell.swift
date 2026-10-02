import DesignSystem
import SwiftUI

struct CodeCell: View {
    let character: Character?
    let isActive: Bool

    private var borderColor: Color {
        if isActive {
            return Palette.roseStrong
        }
        return character == nil ? .white.opacity(0.95) : Palette.roseStrong.opacity(0.35)
    }

    var body: some View {
        Text(character.map(String.init) ?? "")
            .font(.system(size: 24, weight: .bold, design: .rounded))
            .foregroundStyle(Palette.ink)
            .frame(width: 42, height: 56)
            .background(.white.opacity(0.7), in: .rect(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(borderColor, lineWidth: isActive ? 2 : 1)
            }
            .shadow(color: isActive ? Palette.rose.opacity(0.15) : .clear, radius: 4)
            .accessibilityHidden(true)
    }
}
