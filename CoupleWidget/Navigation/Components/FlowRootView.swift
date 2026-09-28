import MainFeature
import OnboardingFeature
import SignInFeature
import SwiftUI

struct FlowRootView: View {
    let container: AppContainer
    let router: AppRouter

    var body: some View {
        switch router.flow {
        case .launching:
            Color.clear
                .overlay { Image("AppSplachScreen") }
                .clipped()
                .ignoresSafeArea()
        case .signedOut:
            container.makeSignInFeature().view(for: .signIn, navigator: router.signInNavigator)
        case .unpaired:
            container.makeOnboardingFeature().view(for: .name, navigator: router.onboardingNavigator)
        case .paired(let couple):
            container.makeMainFeature(couple: couple).view(for: .home, navigator: router.mainNavigator)
        }
    }
}
