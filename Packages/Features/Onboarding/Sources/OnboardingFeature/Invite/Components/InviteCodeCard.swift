import DesignSystem
import SwiftUI

struct InviteCodeCard: View {
    let ownCode: String
    let isCodeCopied: Bool
    @Binding var partnerCode: String
    var isPartnerCodeFocused: FocusState<Bool>.Binding
    let copy: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            SectionLabel(String(localized: "Your code"))
            Text(ownCode)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .tracking(8)
                .monospacedDigit()
                .foregroundStyle(Palette.ink)
                .padding(.top, Spacing.space2)
                .accessibilityLabel(String(localized: "Your code \(ownCode.map(String.init).joined(separator: " "))"))
            HStack(spacing: Spacing.space2) {
                SecondaryButton(
                    title: isCodeCopied ? String(localized: "Copied") : String(localized: "Copy"),
                    systemImage: "doc.on.doc",
                    action: copy
                )
                SecondaryShareLink(title: String(localized: "Share"), systemImage: "square.and.arrow.up", item: ownCode)
            }
            .padding(.top, Spacing.space3)
            OrDivider()
                .padding(.top, Spacing.space4)
            SectionLabel(String(localized: "Partner’s code"))
                .padding(.top, Spacing.space3)
            CodeField(
                length: InviteViewModel.codeLength,
                text: $partnerCode,
                isFocused: isPartnerCodeFocused
            )
            .padding(.top, Spacing.space2)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .glass(.card, in: .rect(cornerRadius: CornerRadius.container))
    }
}
