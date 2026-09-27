import SwiftUI

public struct HeartShape: Shape {
    public init() {}

    public func path(in rect: CGRect) -> Path {
        let scale = min(rect.width, rect.height) / 14
        let radius = 3.3035 * scale
        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * scale, y: rect.minY + y * scale)
        }
        var path = Path()
        path.move(to: point(7, 12.6))
        path.addLine(to: point(1.9, 7.7))
        path.addArc(center: point(4.45, 5.6), radius: radius, startAngle: .degrees(140.5), endAngle: .degrees(320.5), clockwise: false)
        path.addArc(center: point(9.55, 5.6), radius: radius, startAngle: .degrees(219.5), endAngle: .degrees(399.5), clockwise: false)
        path.closeSubpath()
        return path
    }
}

#Preview {
    HeartShape()
        .fill(Palette.roseStrong)
        .frame(width: 140, height: 140)
}
