import DesignSystem
import Domain
import SwiftUI
import UIKit

struct InviteView: View {
    @State private var model: InviteViewModel
    @FocusState private var isCodeFocused: Bool

    init(model: InviteViewModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        ScreenLayout(
            step: 3,
            of: 3,
            title: String(localized: "Invite or connect"),
            subtitle: String(localized: "Share your code with your partner, or enter the code they sent you."),
            contentSpacing: 29
        ) {
            VStack(spacing: 25) {
                InviteCodeCard(
                    ownCode: model.ownCode,
                    isCodeCopied: model.isCodeCopied,
                    partnerCode: $model.partnerCode,
                    isPartnerCodeFocused: $isCodeFocused
                ) {
                    UIPasteboard.general.string = model.ownCode
                    model.codeCopied()
                }
                .onChange(of: model.partnerCode) { model.normalizePartnerCode() }
                VStack(spacing: Spacing.space2) {
                    WaitingStatus()
                    AlreadyPairedButton(isChecking: model.state == .checking) {
                        Task { await model.checkPairing() }
                    }
                }
            }
        } actions: {
            PrimaryButton(title: String(localized: "Connect"), isLoading: model.state == .connecting) {
                Task { await model.connect() }
            }
            .disabled(!model.canConnect)
        }
        .alert(model.alertMessage ?? "", isPresented: $model.isAlertPresented) {
            Button(String(localized: "OK")) {}
        }
    }
}

#Preview {
    InviteView(model: InviteViewModel(
        pairingCode: "K7M2QX",
        joinCouple: PreviewJoinCoupleUseCase(),
        currentCouple: PreviewCurrentCoupleUseCase(),
        navigator: .preview
    ))
}

private struct PreviewJoinCoupleUseCase: JoinCoupleUseCase {
    func callAsFunction(inviteCode: String) async throws -> CoupleID {
        CoupleID(rawValue: UUID())
    }
}

private struct PreviewCurrentCoupleUseCase: CurrentCoupleUseCase {
    func callAsFunction() async throws -> CoupleID? {
        nil
    }
}
