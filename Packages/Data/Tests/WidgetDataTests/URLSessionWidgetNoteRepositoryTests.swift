import Domain
import Foundation
import Testing
import WidgetData

struct URLSessionWidgetNoteRepositoryTests {
    private static let baseURL = URL(string: "https://example.supabase.co") ?? URL(filePath: "/")

    @Test
    func requestsLatestNoteWithSecretAndKey() async throws {
        let recorder = RequestRecorder(status: 200, body: "[]")
        let repository = makeRepository(recorder)

        _ = try await repository.latestPartnerNote(secret: "a1b2")

        let request = try #require(await recorder.requests.first)
        #expect(request.url?.absoluteString == "https://example.supabase.co/rest/v1/rpc/latest_partner_note")
        #expect(request.httpMethod == "POST")
        #expect(request.value(forHTTPHeaderField: "apikey") == "key")
        #expect(try body(of: request) == ["widget_secret": "a1b2"])
    }

    @Test
    func mapsRowToPartnerNote() async throws {
        let body = #"[{"author_name":"Anna","text":"Miss you","updated_at":1790860517.5}]"#
        let repository = makeRepository(RequestRecorder(status: 200, body: body))

        let note = try await repository.latestPartnerNote(secret: "a1b2")

        #expect(note == PartnerNote(
            authorName: "Anna",
            text: "Miss you",
            updatedAt: Date(timeIntervalSince1970: 1790860517.5)
        ))
    }

    @Test
    func returnsNothingWhenThereIsNoNote() async throws {
        let repository = makeRepository(RequestRecorder(status: 200, body: "[]"))

        #expect(try await repository.latestPartnerNote(secret: "a1b2") == nil)
    }

    @Test
    func failsWhenResponseIsNotRows() async {
        let repository = makeRepository(RequestRecorder(status: 200, body: "{}"))

        await #expect(throws: CommonError.unknown) {
            try await repository.latestPartnerNote(secret: "a1b2")
        }
    }

    @Test
    func mapsRejectedRequestToUnauthorized() async {
        let repository = makeRepository(RequestRecorder(status: 401, body: ""))

        await #expect(throws: CommonError.unauthorized) {
            try await repository.latestPartnerNote(secret: "a1b2")
        }
    }

    @Test
    func mapsServerFailureToUnknown() async {
        let repository = makeRepository(RequestRecorder(status: 500, body: ""))

        await #expect(throws: CommonError.unknown) {
            try await repository.latestPartnerNote(secret: "a1b2")
        }
    }

    @Test
    func mapsTransportFailureToNetwork() async {
        let repository = URLSessionWidgetNoteRepository(baseURL: Self.baseURL, key: "key") { _ in
            throw URLError(.notConnectedToInternet)
        }

        await #expect(throws: CommonError.network) {
            try await repository.latestPartnerNote(secret: "a1b2")
        }
    }

    @Test
    func registersPushTokenWithSecret() async throws {
        let recorder = RequestRecorder(status: 204, body: "")
        let repository = makeRepository(recorder)

        try await repository.registerPushToken("c3d4", secret: "a1b2")

        let request = try #require(await recorder.requests.first)
        #expect(request.url?.absoluteString == "https://example.supabase.co/rest/v1/rpc/set_widget_push_token")
        #expect(try body(of: request) == ["widget_secret": "a1b2", "widget_token": "c3d4"])
    }

    private func makeRepository(_ recorder: RequestRecorder) -> URLSessionWidgetNoteRepository {
        URLSessionWidgetNoteRepository(baseURL: Self.baseURL, key: "key") { request in
            try await recorder.respond(to: request)
        }
    }

    private func body(of request: URLRequest) throws -> [String: String]? {
        let data = try #require(request.httpBody)
        return try JSONSerialization.jsonObject(with: data) as? [String: String]
    }
}

private actor RequestRecorder {
    private(set) var requests: [URLRequest] = []

    private let status: Int
    private let body: String

    init(status: Int, body: String) {
        self.status = status
        self.body = body
    }

    func respond(to request: URLRequest) throws -> (Data, URLResponse) {
        requests.append(request)
        guard
            let url = request.url,
            let response = HTTPURLResponse(url: url, statusCode: status, httpVersion: nil, headerFields: nil)
        else {
            throw URLError(.badURL)
        }
        return (Data(body.utf8), response)
    }
}
