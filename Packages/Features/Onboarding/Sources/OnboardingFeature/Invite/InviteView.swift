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
                codeCard
                WaitingStatus()
            }
        } actions: {
            PrimaryButton(title: String(localized: "Connect"), isLoading: model.state == .connecting) {
                Task { await model.connect() }
            }
            .disabled(!model.canConnect)
        }
    }

    private var codeCard: some View {
        VStack(spacing: 0) {
            SectionLabel(String(localized: "Your code"))
            Text(model.formattedOwnCode)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .tracking(5)
                .monospacedDigit()
                .foregroundStyle(Palette.ink)
                .padding(.top, Spacing.space2)
                .accessibilityLabel(String(localized: "Your code \(model.ownCode.map(String.init).joined(separator: " "))"))
            HStack(spacing: Spacing.space2) {
                SecondaryButton(
                    title: model.isCodeCopied ? String(localized: "Copied") : String(localized: "Copy"),
                    systemImage: "doc.on.doc"
                ) {
                    UIPasteboard.general.string = model.ownCode
                    model.codeCopied()
                }
                SecondaryButton(title: String(localized: "Share"), systemImage: "square.and.arrow.up") {}
            }
            .padding(.top, Spacing.space3)
            OrDivider()
                .padding(.top, Spacing.space4)
            SectionLabel(String(localized: "Partner’s code"))
                .padding(.top, Spacing.space3)
            CodeField(
                placeholder: String(localized: "Enter 6 characters"),
                text: $model.partnerCode,
                isFocused: $isCodeFocused
            )
            .submitLabel(.done)
            .onChange(of: model.partnerCode) { model.normalizePartnerCode() }
            .padding(.top, Spacing.space2)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .glass(.card, in: .rect(cornerRadius: CornerRadius.container))
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
