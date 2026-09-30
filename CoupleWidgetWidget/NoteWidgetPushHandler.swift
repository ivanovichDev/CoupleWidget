import Foundation
import NoteCache
import WidgetKit

nonisolated struct NoteWidgetPushHandler: WidgetPushHandler {
    func pushTokenDidChange(_ pushInfo: WidgetPushInfo, widgets: [WidgetInfo]) {
        let token = pushInfo.token.map { String(format: "%02x", $0) }.joined()
        try? WidgetPushTokenStore()?.save(token)
    }
}
