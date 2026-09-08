import Combine
import Foundation
import WatchKit

@MainActor
final class WatchTimerModel: ObservableObject {
    @Published private(set) var snapshot: SharedTimerSnapshot
    private var refreshTimer: AnyCancellable?
    private var lastRefreshDate = Date()

    init() {
        // A fresh Watch install must not overwrite an already-running phone
        // session before it has received the phone's application context.
        let initial = SharedTimerRepository.load() ?? .ready(
            configuration: .standardBoxing,
            at: .distantPast
        )
        snapshot = initial
        SharedTimerRepository.save(initial)

        WatchConnectivityBridge.shared.activate { [weak self] remoteSnapshot in
            self?.snapshot = remoteSnapshot
            self?.lastRefreshDate = Date()
        }

        refreshTimer = Timer.publish(every: 0.25, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.refresh()
            }
    }

    func toggle() {
        let current = snapshot.resolved()
        if current.status == .completed {
            apply(current.applying(.reset).applying(.start))
        } else {
            apply(current.applying(current.isActive ? .pause : .start))
        }
    }

    func reset() {
        apply(snapshot.applying(.reset))
    }

    private func apply(_ updated: SharedTimerSnapshot) {
        snapshot = SharedTimerRepository.save(updated)
        lastRefreshDate = Date()
        WatchConnectivityBridge.shared.send(updated)
    }

    private func refresh() {
        let now = Date()
        let previous = snapshot.resolved(at: lastRefreshDate)
        let current = snapshot.resolved(at: now)

        if now.timeIntervalSince(lastRefreshDate) < 0.75,
           current.configuration.hapticsEnabled ?? true {
            playHaptics(from: previous, to: current)
        }

        objectWillChange.send()
        lastRefreshDate = now
    }

    private func playHaptics(from previous: SharedTimerSnapshot, to current: SharedTimerSnapshot) {
        if previous.status == .countdown, current.status == .running {
            WKInterfaceDevice.current().play(.start)
            return
        }

        if previous.status == .running,
           previous.phase == .work,
           current.phase == .work,
           previous.currentRound == current.currentRound,
           previous.timeRemaining(at: lastRefreshDate) > 10,
           current.timeRemaining() <= 10 {
            WKInterfaceDevice.current().play(.notification)
        }

        guard previous.status == .running,
              (previous.phase != current.phase ||
               previous.currentRound != current.currentRound ||
               current.status == .completed) else { return }

        if current.status == .completed || current.phase == .rest {
            WKInterfaceDevice.current().play(.stop)
        } else {
            WKInterfaceDevice.current().play(.start)
        }
    }
}
