import Combine
import Foundation

@MainActor
final class WatchTimerModel: ObservableObject {
    @Published private(set) var snapshot: SharedTimerSnapshot
    private var refreshTimer: AnyCancellable?

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
        }

        refreshTimer = Timer.publish(every: 0.25, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
    }

    func toggle() {
        let current = snapshot.resolved()
        apply(current.applying(current.isActive ? .pause : .start))
    }

    func reset() {
        apply(snapshot.applying(.reset))
    }

    private func apply(_ updated: SharedTimerSnapshot) {
        snapshot = SharedTimerRepository.save(updated)
        WatchConnectivityBridge.shared.send(updated)
    }
}
