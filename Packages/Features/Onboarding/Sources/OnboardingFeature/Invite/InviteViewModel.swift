import Domain
import Foundation
import Observation

@Observable
final class InviteViewModel {
    enum State: Equatable {
        case idle
        case connecting
        case checking
    }

    static let codeLength = 6

    let ownCode: String
    private(set) var isCodeCopied = false
    private(set) var state: State = .idle
    private(set) var alertMessage: String?

    var partnerCode = ""

    var canConnect: Bool {
        partnerCode.count == Self.codeLength && state == .idle
    }

    var isAlertPresented: Bool {
        get { alertMessage != nil }
        set {
            if !newValue {
                alertMessage = nil
            }
        }
    }

    private let joinCouple: JoinCoupleUseCase
    private let currentCouple: CurrentCoupleUseCase
    private let navigator: OnboardingNavigator

    init(
        pairingCode: String,
        joinCouple: JoinCoupleUseCase,
        currentCouple: CurrentCoupleUseCase,
        navigator: OnboardingNavigator
    ) {
        ownCode = pairingCode
        self.joinCouple = joinCouple
        self.currentCouple = currentCouple
        self.navigator = navigator
    }

    func normalizePartnerCode() {
        let allowed = partnerCode.uppercased().filter { $0.isASCII && ($0.isLetter || $0.isNumber) }
        let normalized = String(allowed.prefix(Self.codeLength))
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
        defer { state = .idle }
        do {
            let couple = try await joinCouple(inviteCode: partnerCode)
            navigator.output(.paired(couple))
        } catch let error as CoupleError {
            alertMessage = Self.message(for: error)
        } catch {
            return
        }
    }

    func checkPairing() async {
        guard state == .idle else { return }
        state = .checking
        defer { state = .idle }
        do {
            if let couple = try await currentCouple() {
                navigator.output(.paired(couple))
            } else {
                alertMessage = String(localized: "Your partner hasn’t connected yet.")
            }
        } catch {
            return
        }
    }

    private static func message(for error: CoupleError) -> String {
        switch error {
        case .ownInviteCode:
            String(localized: "That’s your own code. Enter your partner’s code.")
        case .invalidInviteCode, .inviteCodeNotFound:
            String(localized: "No one has this code. Check it and try again.")
        case .partnerAlreadyPaired:
            String(localized: "This person is already paired with someone else.")
        }
    }
}
