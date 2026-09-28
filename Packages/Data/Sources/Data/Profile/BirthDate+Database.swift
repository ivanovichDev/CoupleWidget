import Domain
import Foundation

extension BirthDate {
    init?(databaseValue: String) {
        let parts = databaseValue.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return nil }
        self.init(year: parts[0], month: parts[1], day: parts[2])
    }

    var databaseValue: String {
        String(format: "%04d-%02d-%02d", year, month, day)
    }
}
