import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    var pushNotificationRegistrar: PushNotificationRegistrar?

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        guard let pushNotificationRegistrar else { return }
        Task { await pushNotificationRegistrar.register(deviceToken: deviceToken) }
    }
}
