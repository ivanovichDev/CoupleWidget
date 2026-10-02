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
        await WidgetCenter.shared.currentPushInfo.map { PushTokenFormat.hexString(from: $0.token) }
    }

    private static var environment: PushEnvironment {
        #if DEBUG
        .sandbox
        #else
        .production
        #endif
    }
}
