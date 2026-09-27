import SwiftUI
import UIKit

struct InlineDatePicker: UIViewRepresentable {
    @Binding var date: Date
    let range: ClosedRange<Date>
    let calendar: Calendar
    let tint: Color

    func makeCoordinator() -> Coordinator {
        Coordinator(date: $date)
    }

    func makeUIView(context: Context) -> UIDatePicker {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .inline
        picker.addTarget(context.coordinator, action: #selector(Coordinator.dateChanged(_:)), for: .valueChanged)
        picker.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return picker
    }

    func updateUIView(_ picker: UIDatePicker, context: Context) {
        context.coordinator.date = $date
        picker.calendar = calendar
        picker.minimumDate = range.lowerBound
        picker.maximumDate = range.upperBound
        picker.tintColor = UIColor(tint)
        if picker.date != date {
            picker.date = date
        }
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView picker: UIDatePicker, context: Context) -> CGSize? {
        guard let width = proposal.width, width > 0 else { return nil }
        let size = picker.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return CGSize(width: width, height: size.height)
    }

    final class Coordinator: NSObject {
        var date: Binding<Date>

        init(date: Binding<Date>) {
            self.date = date
        }

        @objc func dateChanged(_ picker: UIDatePicker) {
            date.wrappedValue = picker.date
        }
    }
}
