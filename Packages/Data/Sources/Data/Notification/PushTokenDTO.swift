import Domain

struct PushTokenDTO: Encodable {
    let token: String
    let kind: String
    let environment: String
}

extension PushTokenDTO {
    init(_ token: PushToken) {
        self.init(
            token: token.value,
            kind: token.kind.databaseValue,
            environment: token.environment.databaseValue
        )
    }
}

extension PushTokenKind {
    var databaseValue: String {
        switch self {
        case .alert: "alert"
        case .widget: "widget"
        }
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
