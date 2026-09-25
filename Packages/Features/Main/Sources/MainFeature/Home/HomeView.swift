import DesignSystem
import Domain
import SwiftUI

struct HomeView: View {
    @State private var model: HomeViewModel

    init(model: HomeViewModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        ScreenLayout(title: String(localized: "Home")) {
            EmptyView()
        } actions: {
            EmptyView()
        }
    }
}

#Preview("Light") {
    HomeView(model: HomeViewModel(couple: CoupleID(rawValue: UUID()), navigator: .preview))
}

#Preview("Dark") {
    HomeView(model: HomeViewModel(couple: CoupleID(rawValue: UUID()), navigator: .preview))
        .preferredColorScheme(.dark)
}
