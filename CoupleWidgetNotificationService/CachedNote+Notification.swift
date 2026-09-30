import Foundation
import NoteCache
import UserNotifications

extension CachedNote {
    init?(notification content: UNNotificationContent) {
        guard
            let note = content.userInfo["note"] as? [String: Any],
            let authorName = note["author_name"] as? String,
            let updatedAt = note["updated_at"] as? NSNumber,
            !content.body.isEmpty
        else {
            return nil
        }
        self.init(
            authorName: authorName,
            text: content.body,
            updatedAt: Date(timeIntervalSince1970: updatedAt.doubleValue)
        )
    }
}
