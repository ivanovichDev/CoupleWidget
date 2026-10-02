import Domain
import NoteCache
import WidgetKit

final class WidgetRegistrar {
    private let registerWidgetSecret: RegisterWidgetSecretUseCase

    init(registerWidgetSecret: RegisterWidgetSecretUseCase) {
        self.registerWidgetSecret = registerWidgetSecret
    }

    func register() async {
        guard let secret = try? WidgetSecretStore()?.readOrCreate() else { return }
        try? await registerWidgetSecret(
            secret: secret,
            environment: Self.environment,
            pushToken: await Self.currentPushToken()
        )
    }

    @concurrent
    private static func currentPushToken() async -> String? {
        if let info = await WidgetCenter.shared.currentPushInfo {
            return WidgetPushTokenStore.hexString(from: info.token)
        }
        return WidgetPushTokenStore()?.read()
    }

    private static var environment: PushEnvironment {
        #if DEBUG
        .sandbox
        #else
        .production
        #endif
    }
}
