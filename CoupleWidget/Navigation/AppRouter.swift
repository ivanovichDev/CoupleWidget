import Domain
import MainFeature
import Observation
import OnboardingFeature
import SignInFeature
import SwiftUI

@Observable
final class AppRouter {
    private(set) var rootScreen: RootScreen = .splash
    var path = NavigationPath()

    private let sessionState: SessionStateUseCase
    private let partnerName: PartnerNameUseCase
    private let messageQuota: MessageQuotaUseCase

    init(sessionState: SessionStateUseCase, partnerName: PartnerNameUseCase, messageQuota: MessageQuotaUseCase) {
        self.sessionState = sessionState
        self.partnerName = partnerName
        self.messageQuota = messageQuota
    }

    func start() async {
        guard rootScreen == .splash else { return }
        await showCurrentSession()
    }

    func push(_ route: SignInRoute) {
        path.append(route)
    }

    func push(_ route: OnboardingRoute) {
        path.append(route)
    }

    func push(_ route: MainRoute) {
        path.append(route)
    }

    func dismiss() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func handle(_ output: SignInOutput) {
        switch output {
        case .signedIn:
            Task { await showCurrentSession() }
        }
    }

    func handle(_ output: OnboardingOutput) {
        switch output {
        case .paired(let couple):
            Task { await showHome(couple) }
        }
    }

    var signInNavigator: SignInNavigator {
        SignInNavigator(
            push: { [weak self] in self?.push($0) },
            dismiss: { [weak self] in self?.dismiss() },
            output: { [weak self] in self?.handle($0) }
        )
    }

    var onboardingNavigator: OnboardingNavigator {
        OnboardingNavigator(
            push: { [weak self] in self?.push($0) },
            dismiss: { [weak self] in self?.dismiss() },
            output: { [weak self] in self?.handle($0) }
        )
    }

    var mainNavigator: MainNavigator {
        MainNavigator(
            push: { [weak self] in self?.push($0) },
            dismiss: { [weak self] in self?.dismiss() }
        )
    }

    private func showCurrentSession() async {
        do {
            switch try await sessionState() {
            case .signedOut:
                setRootScreen(.signIn)
            case .profileIncomplete:
                setRootScreen(.onboarding(.name))
            case .unpaired(let profile):
                setRootScreen(.onboarding(.invite(pairingCode: profile.pairingCode)))
            case .paired(let couple):
                await showHome(couple)
            }
        } catch {
            setRootScreen(.signIn)
        }
    }

    private func showHome(_ couple: CoupleID) async {
        async let name = try? partnerName()
        async let quota = try? messageQuota()
        setRootScreen(.home(HomeSession(couple: couple, partnerName: await name, quota: await quota)))
    }

    private func setRootScreen(_ rootScreen: RootScreen) {
        path = NavigationPath()
        self.rootScreen = rootScreen
    }
}
