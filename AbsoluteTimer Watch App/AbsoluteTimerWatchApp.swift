import SwiftUI

@main
struct AbsoluteTimerWatchApp: App {
    @StateObject private var model = WatchTimerModel()

    var body: some Scene {
        WindowGroup {
            WatchTimerView()
                .environmentObject(model)
        }
    }
}
