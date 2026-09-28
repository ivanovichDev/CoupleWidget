import DesignSystem
import SwiftUI

struct PageDots: View {
    @Binding var selection: WidgetSize?

    var body: some View {
        HStack(spacing: 0) {
            ForEach(WidgetSize.allCases, id: \.self) { size in
                Button {
                    withAnimation { selection = size }
                } label: {
                    Circle()
                        .fill(size == selection ? Palette.roseStrong : Palette.rose.opacity(0.35))
                        .frame(width: 8, height: 8)
                        .frame(width: 16, height: 20)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(size.name)
            }
        }
    }
}
