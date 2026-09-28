import Foundation

public struct BirthDate: Hashable, Sendable {
    public static let minimumAge = 13
    public static let maximumAge = 150

    public let year: Int
    public let month: Int
    public let day: Int

    public init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    public init(date: Date, calendar: Calendar) {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        self.init(year: components.year ?? 0, month: components.month ?? 0, day: components.day ?? 0)
    }

    public static func allowedRange(now: Date, calendar: Calendar) -> ClosedRange<Date> {
        let today = calendar.startOfDay(for: now)
        let earliest = calendar.date(byAdding: .year, value: -maximumAge, to: today) ?? today
        let latest = calendar.date(byAdding: .year, value: -minimumAge, to: today) ?? today
        return earliest...latest
    }

    public func date(in calendar: Calendar) -> Date? {
        let components = DateComponents(year: year, month: month, day: day)
        guard components.isValidDate(in: calendar) else { return nil }
        return calendar.date(from: components)
    }
}
