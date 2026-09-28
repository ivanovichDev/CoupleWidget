import Domain
import Supabase

extension CoupleError {
    init?(joinError: PostgrestError) {
        switch joinError.message {
        case "own_invite_code":
            self = .ownInviteCode
        case "invite_code_not_found":
            self = .inviteCodeNotFound
        case "partner_already_paired":
            self = .partnerAlreadyPaired
        default:
            return nil
        }
    }
}
