import Domain
import Foundation
import Testing
@testable import Data

struct CommonErrorMappingTests {
    @Test
    func urlErrorBecomesNetwork() {
        #expect(CommonError(URLError(.notConnectedToInternet)) == .network)
    }

    @Test
    func commonErrorIsPreserved() {
        #expect(CommonError(CommonError.unauthorized) == .unauthorized)
    }

    @Test
    func otherErrorsBecomeUnknown() {
        struct SomeError: Error {}
        #expect(CommonError(SomeError()) == .unknown)
    }
}
