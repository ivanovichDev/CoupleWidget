import Domain

struct WidgetSecretDTO: Encodable {
    let widgetSecret: String
    let environment: String
    let widgetToken: String?

    enum CodingKeys: String, CodingKey {
        case widgetSecret = "widget_secret"
        case environment
        case widgetToken = "widget_token"
    }
}

extension WidgetSecretDTO {
    init(secret: String, environment: PushEnvironment, pushToken: String?) {
        self.init(widgetSecret: secret, environment: environment.databaseValue, widgetToken: pushToken)
    }
}

extension PushEnvironment {
    var databaseValue: String {
        switch self {
        case .sandbox: "sandbox"
        case .production: "production"
        }
    }
}
