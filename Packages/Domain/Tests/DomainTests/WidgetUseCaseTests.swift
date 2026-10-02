import Domain
import Foundation
import Testing

struct WidgetUseCaseTests {
    @Test
    func fetchReturnsNoteFromRepository() async throws {
        let note = PartnerNote(authorName: "Anna", text: "Miss you", updatedAt: Date(timeIntervalSince1970: 1))
        let repository = RecordingWidgetNoteRepository(note: note)

        let fetched = try await AppFetchPartnerNoteUseCase(repository: repository)(secret: "a1b2")

        #expect(fetched == note)
        #expect(await repository.secrets == ["a1b2"])
    }

    @Test
    func registerPushTokenPassesTokenAndSecret() async throws {
        let repository = RecordingWidgetNoteRepository(note: nil)

        try await AppRegisterWidgetPushTokenUseCase(repository: repository)("c3d4", secret: "a1b2")

        #expect(await repository.registrations == ["c3d4:a1b2"])
    }

    @Test
    func registerSecretPassesAllValues() async throws {
        let repository = RecordingWidgetSecretRepository()

        try await AppRegisterWidgetSecretUseCase(repository: repository)(
            secret: "a1b2",
            environment: .sandbox,
            pushToken: "c3d4"
        )

        #expect(await repository.registrations == ["a1b2:sandbox:c3d4"])
    }
}

private actor RecordingWidgetNoteRepository: WidgetNoteRepository {
    private(set) var secrets: [String] = []
    private(set) var registrations: [String] = []

    private let note: PartnerNote?

    init(note: PartnerNote?) {
        self.note = note
    }

    func latestPartnerNote(secret: String) async throws -> PartnerNote? {
        secrets.append(secret)
        return note
    }

    func registerPushToken(_ token: String, secret: String) async throws {
        registrations.append("\(token):\(secret)")
    }
}

private actor RecordingWidgetSecretRepository: WidgetSecretRepository {
    private(set) var registrations: [String] = []

    func register(secret: String, environment: PushEnvironment, pushToken: String?) async throws {
        registrations.append("\(secret):\(environment):\(pushToken ?? "none")")
    }
}
