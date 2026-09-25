import Domain
import SwiftUI

public struct MainFeature {
    private let couple: CoupleID

    public init(couple: CoupleID) {
        self.couple = couple
    }

    @ViewBuilder
    public func view(for route: MainRoute, navigator: MainNavigator) -> some View {
        switch route {
        case .home:
            HomeView(model: HomeViewModel(couple: couple, navigator: navigator))
        }
    }
}
