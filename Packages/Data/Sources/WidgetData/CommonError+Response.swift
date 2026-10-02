import Domain
import Foundation

extension CommonError {
    init(_ error: any Error) {
        switch error {
        case let error as CommonError:
            self = error
        case is URLError:
            self = .network
        default:
            self = .unknown
        }
    }

    init(statusCode: Int) {
        self = statusCode == 401 || statusCode == 403 ? .unauthorized : .unknown
    }
}
