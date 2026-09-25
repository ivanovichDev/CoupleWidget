import DesignSystem
import SwiftUI

struct BirthdayView: View {
    @State private var model: BirthdayViewModel

    init(model: BirthdayViewModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        ScreenLayout(
            title: String(localized: "When's your birthday?"),
            subtitle: String(localized: "We'll remind your partner about it")
        ) {
            DatePicker(
                String(localized: "Birthday"),
                selection: $model.birthday,
                in: model.range,
                displayedComponents: .date
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .frame(maxWidth: .infinity)
        } actions: {
            PrimaryButton(title: String(localized: "Continue"), action: model.submit)
        }
    }
}

#Preview("Light") {
    BirthdayView(model: BirthdayViewModel(navigator: .preview))
}

#Preview("Dark") {
    BirthdayView(model: BirthdayViewModel(navigator: .preview))
        .preferredColorScheme(.dark)
}
