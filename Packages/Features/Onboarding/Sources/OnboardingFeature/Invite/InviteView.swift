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
                    formattedOwnCode: model.formattedOwnCode,
                    isCodeCopied: model.isCodeCopied,
                    partnerCode: $model.partnerCode,
                    isPartnerCodeFocused: $isCodeFocused
                ) {
                    UIPasteboard.general.string = model.ownCode
                    model.codeCopied()
                }
                .onChange(of: model.partnerCode) { model.normalizePartnerCode() }
                WaitingStatus()
            }
        } actions: {
            PrimaryButton(title: String(localized: "Connect"), isLoading: model.state == .connecting) {
                Task { await model.connect() }
            }
            .disabled(!model.canConnect)
        }
    }
}

#Preview {
    InviteView(model: InviteViewModel(joinCouple: PreviewJoinCoupleUseCase(), navigator: .preview))
}

private struct PreviewJoinCoupleUseCase: JoinCoupleUseCase {
    func callAsFunction(inviteCode: String) async throws -> CoupleID {
        CoupleID(rawValue: UUID())
    }
}
