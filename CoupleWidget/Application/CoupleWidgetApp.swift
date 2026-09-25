import SwiftUI

@main
struct CoupleWidgetApp: App {
    @State private var router = AppRouter()
    private let container = AppContainer(configuration: .current)

    var body: some Scene {
        WindowGroup {
            RootView(container: container, router: router)
        }
    }
}
