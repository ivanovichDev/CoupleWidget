import CoreGraphics
import SwiftUI

public enum WidgetSize: CaseIterable, Hashable, Identifiable, Sendable {
    case small
    case medium
    case large

    public var id: Self { self }

    public var name: String {
        switch self {
        case .small: String(localized: "Small widget")
        case .medium: String(localized: "Medium widget")
        case .large: String(localized: "Large widget")
        }
    }

    public var size: CGSize {
        switch self {
        case .small: CGSize(width: 158, height: 158)
        case .medium: CGSize(width: 338, height: 158)
        case .large: CGSize(width: 338, height: 354)
        }
    }

    public var textFont: Font {
        switch self {
        case .small: Typography.subheadline.weight(.semibold)
        case .medium: Typography.headline
        case .large: Typography.title2
        }
    }

    public var footerFont: Font {
        switch self {
        case .small: Font.caption
        case .medium, .large: Typography.footnote
        }
    }

    public var lineLimit: Int {
        switch self {
        case .small: 5
        case .medium: 4
        case .large: 10
        }
    }
}
