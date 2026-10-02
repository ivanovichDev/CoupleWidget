import SwiftUI

public struct SecondaryShareLink: View {
    private let title: String
    private let systemImage: String
    private let item: String

    public init(title: String, systemImage: String, item: String) {
        self.title = title
        self.systemImage = systemImage
        self.item = item
    }

    public var body: some View {
        ShareLink(item: item) {
            SecondaryButtonLabel(title: title, systemImage: systemImage)
        }
        .buttonStyle(.plain)
    }
}
