import DesignSystem
import SwiftUI

struct WidgetCarousel: View {
    static let dynamicIslandInset: CGFloat = 12
    private static let widgetAreaHeight: CGFloat = 403
    private static let dotInset: CGFloat = 6

    let text: String
    let scale: CGFloat
    @Binding var selection: WidgetSize?

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    ForEach(WidgetSize.allCases, id: \.self) { size in
                        WidgetPreview(size: size, text: text)
                            .offset(y: Self.dotInset / 2)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .scaleEffect(scale, anchor: .top)
                            .containerRelativeFrame(.horizontal)
                            .id(size)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $selection)
            .scrollIndicators(.hidden)
            .scrollClipDisabled()
            .frame(height: Self.widgetAreaHeight)
            PageDots(selection: $selection)
                .scaleEffect(scale, anchor: .top)
                .padding(.top, -Self.widgetAreaHeight * (1 - scale))
        }
        .animation(.timingCurve(0.25, 1, 0.5, 1, duration: 0.35), value: scale)
    }
}

private struct PageDots: View {
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
