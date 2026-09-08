import Foundation
import UserNotifications

enum SharedTimerNotifications {
    private static let identifierPrefix = "absolute-timer."

    static func requestAuthorizationAndSchedule(_ snapshot: SharedTimerSnapshot) async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        var authorized = settings.authorizationStatus == .authorized ||
            settings.authorizationStatus == .provisional
#if os(iOS)
        authorized = authorized || settings.authorizationStatus == .ephemeral
#endif

        if settings.authorizationStatus == .notDetermined {
            authorized = (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
        }

        guard authorized,
              SharedTimerRepository.load()?.mutationID == snapshot.mutationID else { return }
        await schedule(snapshot)
    }

    static func schedule(_ snapshot: SharedTimerSnapshot) async {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        guard snapshot.isActive,
              SharedTimerRepository.load()?.mutationID == snapshot.mutationID else { return }
        let now = Date()

        for (index, event) in snapshot.futureEvents(after: now).enumerated() {
            let interval = event.date.timeIntervalSince(now)
            guard interval >= 1 else { continue }

            let content = UNMutableNotificationContent()
            content.sound = notificationSound(
                for: event.kind,
                enabled: snapshot.configuration.soundEnabled ?? true
            )
            content.threadIdentifier = "absolute-timer-session"

            switch event.kind {
            case .countdownTick(let seconds):
                content.title = "Starting in \(seconds)"
                content.body = "Get ready."
            case .warning:
                content.title = "10 seconds"
                content.body = "Round \(event.round) is almost over."
            case .restStarted:
                content.title = "Rest"
                content.body = "Round \(event.round) complete."
            case .roundStarted:
                content.title = event.round == snapshot.configuration.totalRounds
                    ? "Final Round"
                    : "Round \(event.round)"
                content.body = "Work interval started."
            case .completed:
                content.title = "Time"
                content.body = "Workout complete."
            }

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
            let request = UNNotificationRequest(
                identifier: "\(identifierPrefix)\(snapshot.sessionID.uuidString).\(index)",
                content: content,
                trigger: trigger
            )
            try? await center.add(request)
        }
    }

    static func cancel() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    private static func notificationSound(
        for kind: SharedTimerEvent.Kind,
        enabled: Bool
    ) -> UNNotificationSound? {
        guard enabled else { return nil }

#if os(watchOS)
        return .default
#else
        let name: String
        switch kind {
        case .countdownTick:
            name = "countdown.wav"
        case .warning:
            name = "warning-double.wav"
        case .roundStarted:
            name = "start.wav"
        case .restStarted, .completed:
            name = "bell.wav"
        }
        return UNNotificationSound(named: UNNotificationSoundName(rawValue: name))
#endif
    }
}
