import Domain
import Foundation
import NoteCache
import WidgetData

nonisolated struct WidgetContainer {
    let fetchPartnerNote: FetchPartnerNoteUseCase
    let registerPushToken: RegisterWidgetPushTokenUseCase
    let secretStore: WidgetSecretStore?

    init?(bundle: Bundle = .main) {
        guard
            let urlString = bundle.object(forInfoDictionaryKey: "SupabaseURL") as? String,
            let url = URL(string: urlString),
            let key = bundle.object(forInfoDictionaryKey: "SupabaseKey") as? String,
            !key.isEmpty
        else {
            return nil
        }
        let repository = URLSessionWidgetNoteRepository(baseURL: url, key: key)
        fetchPartnerNote = AppFetchPartnerNoteUseCase(repository: repository)
        registerPushToken = AppRegisterWidgetPushTokenUseCase(repository: repository)
        secretStore = WidgetSecretStore()
    }
}
