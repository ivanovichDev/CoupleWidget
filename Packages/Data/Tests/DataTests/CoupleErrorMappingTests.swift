import Domain
import Supabase
import Testing
@testable import Data

struct CoupleErrorMappingTests {
    @Test(arguments: [
        ("own_invite_code", CoupleError.ownInviteCode),
        ("invite_code_not_found", CoupleError.inviteCodeNotFound),
        ("partner_already_paired", CoupleError.partnerAlreadyPaired)
    ])
    func knownJoinErrorsBecomeCoupleErrors(message: String, expected: CoupleError) {
        #expect(CoupleError(joinError: PostgrestError(code: "P0001", message: message)) == expected)
    }

    @Test
    func otherErrorsAreNotCoupleErrors() {
        #expect(CoupleError(joinError: PostgrestError(code: "42501", message: "permission denied")) == nil)
    }
}
