import Foundation
import NoteCache
import UserNotifications
import WidgetKit

final class NotificationService: UNNotificationServiceExtension {
    private static let widgetReloadTimeout: TimeInterval = 5

    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        let note = CachedNote(notification: request.content)
        if let note, (try? NoteCacheStore()?.save(note)) == true {
            let isReloadDelivered = DispatchSemaphore(value: 0)
            WidgetCenter.shared.reloadAllTimelines()
            WidgetCenter.shared.getCurrentConfigurations { _ in
                isReloadDelivered.signal()
            }
            _ = isReloadDelivered.wait(timeout: .now() + Self.widgetReloadTimeout)
        }
        contentHandler(request.content)
    }
}
