import Foundation

struct AppConfiguration {
    let supabaseURL: URL
    let supabaseKey: String
}

extension AppConfiguration {
    static let current = AppConfiguration(
        supabaseURL: supabaseURL,
        supabaseKey: "4f90d8ab59303b930b9093d2b3c54f7958b907e088ad3163"
    )

    private static var supabaseURL: URL {
        guard let url = URL(string: "https://pfogwzatkqejybslfoes.supabase.co") else {
            fatalError("Invalid Supabase URL")
        }
        return url
    }
}
