import DesignSystem
import SwiftUI

struct WidgetPreview: View {
    let size: WidgetSize
    let text: String

    var body: some View {
        WidgetCard {
            Text(text.isEmpty ? String(localized: "Write something sweet…") : text)
                .font(size.textFont)
                .foregroundStyle(text.isEmpty ? Palette.inkMuted : Palette.ink)
                .lineLimit(size.lineLimit)
        } footer: {
            Text(String(localized: "From you"))
                .font(size.footerFont)
                .foregroundStyle(Palette.inkMuted)
        }
        .frame(width: size.size.width, height: size.size.height)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(size.name)
    }
}
