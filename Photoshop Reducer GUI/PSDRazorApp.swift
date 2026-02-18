import SwiftUI

@main
struct PSDRazorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .fixedSize()
        }
        .windowResizability(.contentSize)
    }
}
