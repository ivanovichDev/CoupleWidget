import Domain
import SwiftUI

public struct OnboardingFeature {
    private let joinCouple: JoinCoupleUseCase

    public init(joinCouple: JoinCoupleUseCase) {
        self.joinCouple = joinCouple
    }

    @ViewBuilder
    public func view(for route: OnboardingRoute, navigator: OnboardingNavigator) -> some View {
        switch route {
        case .name:
            NameView(model: NameViewModel(navigator: navigator))
        case .birthday:
            BirthdayView(model: BirthdayViewModel(navigator: navigator))
        case .invite:
            InviteView(model: InviteViewModel(joinCouple: joinCouple, navigator: navigator))
        }
    }
}
