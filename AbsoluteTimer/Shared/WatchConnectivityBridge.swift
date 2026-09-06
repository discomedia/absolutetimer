import Foundation
import WatchConnectivity
#if os(iOS)
import WidgetKit
#endif

final class WatchConnectivityBridge: NSObject, WCSessionDelegate {
    static let shared = WatchConnectivityBridge()

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var receiveHandler: ((SharedTimerSnapshot) -> Void)?

    private override init() {
        super.init()
    }

    func activate(receive: ((SharedTimerSnapshot) -> Void)? = nil) {
        if let receive {
            receiveHandler = receive
        }
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        if session.activationState == .notActivated {
            session.activate()
        }
    }

    func send(_ snapshot: SharedTimerSnapshot) {
        guard WCSession.isSupported(),
              WCSession.default.activationState == .activated,
              let data = try? encoder.encode(snapshot) else { return }

        let payload: [String: Any] = ["timerSnapshot": data]
        try? WCSession.default.updateApplicationContext(payload)

        if WCSession.default.isReachable {
            WCSession.default.sendMessage(payload, replyHandler: nil, errorHandler: nil)
        }
    }

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        guard activationState == .activated else { return }
        if let snapshot = SharedTimerRepository.load() {
            send(snapshot)
        }
        receive(session.receivedApplicationContext)
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        receive(applicationContext)
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        receive(message)
    }

    func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        receive(message)
        if let snapshot = SharedTimerRepository.load(),
           let data = try? encoder.encode(snapshot) {
            replyHandler(["timerSnapshot": data])
        } else {
            replyHandler([:])
        }
    }

    private func receive(_ payload: [String: Any]) {
        guard let data = payload["timerSnapshot"] as? Data,
              let snapshot = try? decoder.decode(SharedTimerSnapshot.self, from: data) else { return }

        DispatchQueue.main.async { [weak self] in
            guard SharedTimerRepository.acceptRemote(snapshot) else { return }
            self?.receiveHandler?(snapshot)
#if os(iOS)
            WidgetCenter.shared.reloadAllTimelines()
            if #available(iOS 18.0, *) {
                ControlCenter.shared.reloadAllControls()
            }
            Task { await SharedTimerNotifications.schedule(snapshot) }
#endif
        }
    }

#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
#endif
}
