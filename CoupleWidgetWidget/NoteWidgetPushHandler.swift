import Domain
import Foundation
import NoteCache
import WidgetKit

nonisolated struct NoteWidgetPushHandler: WidgetPushHandler {
    func pushTokenDidChange(_ pushInfo: WidgetPushInfo, widgets: [WidgetInfo]) {
        let token = WidgetPushTokenStore.hexString(from: pushInfo.token)
        try? WidgetPushTokenStore()?.save(token)
        Task {
            guard
                let container = WidgetContainer(),
                let secret = container.secretStore?.read()
            else { return }
            try? await container.registerPushToken(token, secret: secret)
        }
    }
}
