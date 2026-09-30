import Domain
import Foundation
import Testing

struct SendMessageUseCaseTests {
    @Test
    func trimsTextBeforeSending() async throws {
        let repository = RecordingMessageRepository()
        let useCase = AppSendMessageUseCase(repository: repository)

        _ = try await useCase("  Miss you \n")

        #expect(await repository.sentTexts == ["Miss you"])
    }

    @Test
    func rejectsEmptyText() async {
        let repository = RecordingMessageRepository()
        let useCase = AppSendMessageUseCase(repository: repository)

        await #expect(throws: MessageError.empty) {
            try await useCase("   ")
        }
        #expect(await repository.sentTexts.isEmpty)
    }

    @Test
    func returnsQuotaFromRepository() async throws {
        let useCase = AppSendMessageUseCase(repository: RecordingMessageRepository())

        let quota = try await useCase("Miss you")

        #expect(quota == RecordingMessageRepository.quota)
    }
}

private actor RecordingMessageRepository: MessageRepository {
    static let quota = MessageQuota(
        dailyLimit: 10,
        messagesLeft: 9,
        cooldown: 30,
        cooldownRemaining: 30,
        resetRemaining: 3600
    )

    private(set) var sentTexts: [String] = []

    func quota() async throws -> MessageQuota {
        Self.quota
    }

    func send(_ text: String) async throws -> MessageQuota {
        sentTexts.append(text)
        return Self.quota
    }
}
