import Domain
import Supabase

extension MessageError {
    init?(sendError: PostgrestError) {
        switch sendError.message {
        case "note_too_soon":
            self = .tooSoon
        case "daily_note_limit_reached":
            self = .dailyLimitReached
        default:
            return nil
        }
    }
}
