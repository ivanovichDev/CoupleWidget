import DesignSystem
import Domain
import SwiftUI

struct InviteView: View {
    @State private var model: InviteViewModel
    @FocusState private var isFocused: Bool

    init(model: InviteViewModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        ScreenLayout(
            title: String(localized: "Invite your partner"),
            subtitle: String(localized: "Enter the invite code your partner shared with you")
        ) {
            VStack(alignment: .leading, spacing: Spacing.small) {
                InputField(String(localized: "Invite code"), text: $model.inviteCode, isFocused: $isFocused)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                if case .failed(let message) = model.state {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
        } actions: {
            PrimaryButton(title: String(localized: "Join"), isLoading: model.state == .joining) {
                Task { await model.join() }
            }
        }
    }
}

#Preview("Light") {
    InviteView(model: InviteViewModel(joinCouple: PreviewJoinCoupleUseCase(), navigator: .preview))
}

#Preview("Dark") {
    InviteView(model: InviteViewModel(joinCouple: PreviewJoinCoupleUseCase(), navigator: .preview))
        .preferredColorScheme(.dark)
}

private struct PreviewJoinCoupleUseCase: JoinCoupleUseCase {
    func callAsFunction(inviteCode: String) async throws -> CoupleID {
        CoupleID(rawValue: UUID())
    }
}
