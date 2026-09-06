import AppIntents
import WidgetKit

/// AudioPlaybackIntent makes interactive widget and Control Center actions run
/// in the containing app process, even while it is in the background. That is
/// important here because the app process owns WatchConnectivity.
struct ToggleTimerIntent: AudioPlaybackIntent {
    static let title: LocalizedStringResource = "Start or Pause Timer"
    static let description = IntentDescription("Toggles the current Absolute Timer workout.")

    @MainActor
    func perform() async throws -> some IntentResult {
        let current = (SharedTimerRepository.load() ?? .ready(configuration: .standardBoxing)).resolved()
        let updated = SharedTimerRepository.perform(current.isActive ? .pause : .start)
        await finishTimerMutation(updated)
        return .result()
    }
}

struct SetTimerRunningIntent: SetValueIntent, AudioPlaybackIntent {
    static let title: LocalizedStringResource = "Set Timer Running"

    @Parameter(title: "Running")
    var value: Bool

    @MainActor
    func perform() async throws -> some IntentResult {
        let updated = SharedTimerRepository.perform(.setRunning(value))
        await finishTimerMutation(updated)
        return .result()
    }
}

struct ResetTimerIntent: AudioPlaybackIntent {
    static let title: LocalizedStringResource = "Reset Timer"
    static let description = IntentDescription("Resets the current Absolute Timer workout.")

    @MainActor
    func perform() async throws -> some IntentResult {
        let updated = SharedTimerRepository.perform(.reset)
        await finishTimerMutation(updated)
        return .result()
    }
}

@MainActor
private func finishTimerMutation(_ snapshot: SharedTimerSnapshot) async {
    if snapshot.status == .running {
        await SharedTimerNotifications.requestAuthorizationAndSchedule(snapshot)
    } else {
        SharedTimerNotifications.cancel()
    }

    WidgetCenter.shared.reloadAllTimelines()
    if #available(iOS 18.0, *) {
        ControlCenter.shared.reloadAllControls()
    }

#if TIMER_APP
    WatchConnectivityBridge.shared.activate()
    WatchConnectivityBridge.shared.send(snapshot)
#endif
}
