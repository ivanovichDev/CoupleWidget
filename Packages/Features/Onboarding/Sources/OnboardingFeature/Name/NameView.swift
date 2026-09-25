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
            title: String(localized: "What's your name?"),
            subtitle: String(localized: "Your partner will see it on the widget")
        ) {
            InputField(String(localized: "Name"), text: $model.name, isFocused: $isFocused)
                .textContentType(.givenName)
                .submitLabel(.continue)
                .onSubmit(model.submit)
        } actions: {
            PrimaryButton(title: String(localized: "Continue"), action: model.submit)
                .disabled(!model.canSubmit)
        }
        .onAppear { isFocused = true }
    }
}

#Preview("Light") {
    NameView(model: NameViewModel(navigator: .preview))
}

#Preview("Dark") {
    NameView(model: NameViewModel(navigator: .preview))
        .preferredColorScheme(.dark)
}
