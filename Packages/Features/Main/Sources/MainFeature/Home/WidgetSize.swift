import CoreGraphics
import DesignSystem
import SwiftUI

enum WidgetSize: CaseIterable, Hashable, Identifiable {
    case small
    case medium
    case large

    var id: Self { self }

    var name: String {
        switch self {
        case .small: String(localized: "Small widget")
        case .medium: String(localized: "Medium widget")
        case .large: String(localized: "Large widget")
        }
    }

    var size: CGSize {
        switch self {
        case .small: CGSize(width: 158, height: 158)
        case .medium: CGSize(width: 338, height: 158)
        case .large: CGSize(width: 338, height: 354)
        }
    }

    var textFont: Font {
        switch self {
        case .small: Typography.subheadline.weight(.semibold)
        case .medium: Typography.headline
        case .large: Typography.title2
        }
    }

    var footerFont: Font {
        switch self {
        case .small: Font.caption
        case .medium, .large: Typography.footnote
        }
    }

    var lineLimit: Int {
        switch self {
        case .small: 5
        case .medium: 4
        case .large: 10
        }
    }
}
