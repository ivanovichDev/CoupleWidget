import Domain
import Foundation

public struct URLSessionWidgetNoteRepository: WidgetNoteRepository {
    public typealias Transport = @Sendable (URLRequest) async throws -> (Data, URLResponse)

    private let baseURL: URL
    private let key: String
    private let transport: Transport

    public init(
        baseURL: URL,
        key: String,
        transport: @escaping Transport = { try await URLSession.shared.data(for: $0) }
    ) {
        self.baseURL = baseURL
        self.key = key
        self.transport = transport
    }

    public func latestPartnerNote(secret: String) async throws -> PartnerNote? {
        let data = try await send(function: "latest_partner_note", parameters: ["widget_secret": secret])
        do {
            return try JSONDecoder().decode([PartnerNoteRow].self, from: data).first.map(PartnerNote.init)
        } catch {
            throw CommonError.unknown
        }
    }

    public func registerPushToken(_ token: String, secret: String) async throws {
        _ = try await send(
            function: "set_widget_push_token",
            parameters: ["widget_secret": secret, "widget_token": token]
        )
    }

    private func send(function: String, parameters: [String: String]) async throws -> Data {
        do {
            var request = URLRequest(url: baseURL.appending(path: "rest/v1/rpc/\(function)"))
            request.httpMethod = "POST"
            request.timeoutInterval = 10
            request.setValue(key, forHTTPHeaderField: "apikey")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(parameters)
            let (data, response) = try await transport(request)
            guard let status = (response as? HTTPURLResponse)?.statusCode, (200..<300).contains(status) else {
                throw CommonError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0)
            }
            return data
        } catch {
            throw CommonError(error)
        }
    }
}
