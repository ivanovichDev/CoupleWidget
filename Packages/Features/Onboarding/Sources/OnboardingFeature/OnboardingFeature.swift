import Domain
import SwiftUI

public struct OnboardingFeature {
    private let completeProfile: CompleteProfileUseCase
    private let joinCouple: JoinCoupleUseCase

    public init(completeProfile: CompleteProfileUseCase, joinCouple: JoinCoupleUseCase) {
        self.completeProfile = completeProfile
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
        case .birthday(let name):
            BirthdayView(model: BirthdayViewModel(name: name, completeProfile: completeProfile, navigator: navigator))
        case .invite(let pairingCode):
            InviteView(model: InviteViewModel(pairingCode: pairingCode, joinCouple: joinCouple, navigator: navigator))
        }
    }
}
