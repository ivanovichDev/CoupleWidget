public protocol WidgetNoteRepository: Sendable {
    func latestPartnerNote(secret: String) async throws -> PartnerNote?
    func registerPushToken(_ token: String, secret: String) async throws
}
