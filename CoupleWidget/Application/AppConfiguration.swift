import Foundation

struct AppConfiguration {
    let supabaseURL: URL
    let supabaseKey: String
}

extension AppConfiguration {
    static let current = AppConfiguration(bundle: .main)

    init(bundle: Bundle) {
        guard
            let urlString = bundle.object(forInfoDictionaryKey: "SupabaseURL") as? String,
            let url = URL(string: urlString),
            let key = bundle.object(forInfoDictionaryKey: "SupabaseKey") as? String,
            !key.isEmpty
        else {
            fatalError("Supabase configuration is missing from Info.plist")
        }
        self.init(supabaseURL: url, supabaseKey: key)
    }
}
