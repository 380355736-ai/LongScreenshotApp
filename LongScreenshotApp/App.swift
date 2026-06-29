import SwiftUI

@main
struct LongScreenshotApp: App {
    @StateObject private var recorder = ScreenRecorder()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(recorder)
        }
    }
}
