import Domain
import Foundation
import NoteCache
import UIKit
import UserNotifications

final class PushNotificationRegistrar {
    private let registerPushToken: RegisterPushTokenUseCase

    init(registerPushToken: RegisterPushTokenUseCase) {
        self.registerPushToken = registerPushToken
    }

    func requestAuthorization() async {
        let isGranted = (try? await UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        )) ?? false
        guard isGranted else { return }
        UIApplication.shared.registerForRemoteNotifications()
        await registerWidgetToken()
    }

    func register(deviceToken: Data) async {
        let value = deviceToken.map { String(format: "%02x", $0) }.joined()
        try? await registerPushToken(PushToken(value: value, kind: .alert, environment: Self.environment))
    }

    private func registerWidgetToken() async {
        guard let value = WidgetPushTokenStore()?.read() else { return }
        try? await registerPushToken(PushToken(value: value, kind: .widget, environment: Self.environment))
    }

    private static var environment: PushEnvironment {
        #if DEBUG
        .sandbox
        #else
        .production
        #endif
    }
}
