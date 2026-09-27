import DesignSystem
import SwiftUI

struct BirthdayView: View {
    @State private var model: BirthdayViewModel

    init(model: BirthdayViewModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        ScreenLayout(
            step: 2,
            of: 3,
            title: String(localized: "When’s your birthday?"),
            subtitle: String(localized: "So your partner never misses your special day."),
            contentSpacing: 39
        ) {
            InlineDatePicker(
                date: $model.birthday,
                range: model.range,
                calendar: mondayFirstCalendar,
                tint: Palette.roseStrong
            )
            .padding(.horizontal, Spacing.space2)
            .padding(.top, Spacing.space2)
            .padding(.bottom, 14)
            .glass(.card, in: .rect(cornerRadius: CornerRadius.container))
        } actions: {
            PrimaryButton(title: String(localized: "Continue"), action: model.submit)
        }
    }

    private var mondayFirstCalendar: Calendar {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        return calendar
    }
}

#Preview {
    BirthdayView(model: BirthdayViewModel(navigator: .preview))
}
