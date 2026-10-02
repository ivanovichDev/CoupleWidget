import Domain
import Foundation
import NoteCache
import WidgetKit

nonisolated struct NoteWidgetPushHandler: WidgetPushHandler {
    func pushTokenDidChange(_ pushInfo: WidgetPushInfo, widgets: [WidgetInfo]) {
        let token = PushTokenFormat.hexString(from: pushInfo.token)
        Task {
            guard
                let container = WidgetContainer(),
                let secret = container.secretStore?.read()
            else { return }
            try? await container.registerPushToken(token, secret: secret)
        }
    }
}
