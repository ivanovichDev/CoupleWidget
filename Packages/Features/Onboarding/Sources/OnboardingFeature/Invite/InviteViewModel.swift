import Domain
import Foundation
import Observation

@Observable
final class InviteViewModel {
    enum State: Equatable {
        case idle
        case connecting
        case failed(String)
    }

    static let codeLength = 6

    let ownCode = "K7M2QX"
    private(set) var isCodeCopied = false
    private(set) var state: State = .idle

    var partnerCode = ""

    var formattedOwnCode: String {
        let middle = ownCode.index(ownCode.startIndex, offsetBy: ownCode.count / 2)
        return "\(ownCode[..<middle])·\(ownCode[middle...])"
    }

    var canConnect: Bool {
        partnerCode.count == Self.codeLength && state != .connecting
    }

    private let joinCouple: JoinCoupleUseCase
    private let navigator: OnboardingNavigator

    init(joinCouple: JoinCoupleUseCase, navigator: OnboardingNavigator) {
        self.joinCouple = joinCouple
        self.navigator = navigator
    }

    func normalizePartnerCode() {
        let normalized = String(partnerCode.uppercased().filter { !$0.isWhitespace }.prefix(Self.codeLength))
        if normalized != partnerCode {
            partnerCode = normalized
        }
    }

    func codeCopied() {
        isCodeCopied = true
    }

    func connect() async {
        guard canConnect else { return }
        state = .connecting
        do {
            let couple = try await joinCouple(inviteCode: partnerCode)
            state = .idle
            navigator.output(.paired(couple))
        } catch CoupleError.invalidInviteCode {
            state = .failed(String(localized: "Check the invite code and try again"))
        } catch {
            state = .idle
        }
    }
}
