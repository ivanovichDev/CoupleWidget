import DesignSystem
import SwiftUI

struct NameView: View {
    @State private var model: NameViewModel
    @FocusState private var isFocused: Bool

    init(model: NameViewModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        ScreenLayout(
            step: 1,
            of: 3,
            title: String(localized: "What’s your name?"),
            subtitle: String(localized: "Your partner will see it on every note."),
            contentSpacing: 19
        ) {
            WidgetCard {
                Text(String(localized: "Good morning, sunshine. Coffee is on the stove."))
                    .font(Typography.headline)
                    .foregroundStyle(Palette.ink)
            } footer: {
                NoteAuthorLabel(author)
                    .font(Typography.footnote)
            }
            .frame(height: 158)
            .padding(.horizontal, 10)
        } input: {
            VStack(alignment: .leading, spacing: Spacing.space2) {
                Text(String(localized: "Name"))
                    .font(Typography.footnote)
                    .foregroundStyle(Palette.inkMuted)
                    .padding(.leading, 20)
                InputField(String(localized: "Your name"), text: $model.name, isFocused: $isFocused)
                    .textContentType(.givenName)
                    .submitLabel(.done)
            }
        } actions: {
            PrimaryButton(title: String(localized: "Continue"), action: model.submit)
                .disabled(!model.canSubmit)
        }
    }

    private var author: String {
        let name = model.canSubmit ? model.trimmedName : String(localized: "you")
        return String(localized: "From \(name)")
    }
}

#Preview {
    NameView(model: NameViewModel(navigator: .preview))
}
