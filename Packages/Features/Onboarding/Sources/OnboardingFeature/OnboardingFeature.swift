import Domain
import SwiftUI

public struct OnboardingFeature {
    private let joinCouple: JoinCoupleUseCase

    public init(joinCouple: JoinCoupleUseCase) {
        self.joinCouple = joinCouple
    }

    public func view(for route: OnboardingRoute, navigator: OnboardingNavigator) -> some View {
        screen(for: route, navigator: navigator)
            .navigationBarBackButtonHidden()
    }

    @ViewBuilder
    private func screen(for route: OnboardingRoute, navigator: OnboardingNavigator) -> some View {
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
