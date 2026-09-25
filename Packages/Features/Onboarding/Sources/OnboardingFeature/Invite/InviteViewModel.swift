import Domain
import Foundation
import Observation

@Observable
final class InviteViewModel {
    enum State: Equatable {
        case idle
        case joining
        case failed(String)
    }

    var inviteCode = ""
    private(set) var state: State = .idle

    private let joinCouple: JoinCoupleUseCase
    private let navigator: OnboardingNavigator

    init(joinCouple: JoinCoupleUseCase, navigator: OnboardingNavigator) {
        self.joinCouple = joinCouple
        self.navigator = navigator
    }

    func join() async {
        state = .joining
        do {
            let couple = try await joinCouple(inviteCode: inviteCode)
            state = .idle
            navigator.output(.paired(couple))
        } catch CoupleError.invalidInviteCode {
            state = .failed(String(localized: "Check the invite code and try again"))
        } catch {
            state = .idle
        }
    }
}
