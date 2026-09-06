import Foundation

enum SharedTimerPhase: String, Codable, Sendable {
    case work
    case rest
}

enum SharedTimerStatus: String, Codable, Sendable {
    case ready
    case running
    case paused
    case completed
}

enum SharedTimerAction: Sendable {
    case start
    case pause
    case reset
    case setRunning(Bool)
}

struct SharedTimerConfiguration: Codable, Equatable, Sendable {
    var profileID: UUID
    var profileName: String
    var roundDuration: Int
    var breakDuration: Int
    var totalRounds: Int

    static let standardBoxing = SharedTimerConfiguration(
        profileID: UUID(uuidString: "4E82A9CF-26A6-4CC4-9955-B47671B1B711")!,
        profileName: "Standard Boxing",
        roundDuration: 180,
        breakDuration: 60,
        totalRounds: 12
    )
}

struct SharedTimerSnapshot: Codable, Equatable, Sendable {
    static let currentSchemaVersion = 1

    var schemaVersion = currentSchemaVersion
    var sessionID: UUID
    var mutationID: UUID
    var modifiedAt: Date
    var configuration: SharedTimerConfiguration
    var status: SharedTimerStatus
    var phase: SharedTimerPhase
    var currentRound: Int
    var phaseEndDate: Date?
    var pausedRemaining: TimeInterval

    static func ready(
        configuration: SharedTimerConfiguration,
        at date: Date = Date()
    ) -> SharedTimerSnapshot {
        SharedTimerSnapshot(
            sessionID: UUID(),
            mutationID: UUID(),
            modifiedAt: date,
            configuration: configuration,
            status: .ready,
            phase: .work,
            currentRound: 1,
            phaseEndDate: nil,
            pausedRemaining: TimeInterval(configuration.roundDuration)
        )
    }

    var hasStarted: Bool {
        status != .ready
    }

    var isActive: Bool {
        status == .running
    }

    var isCompleted: Bool {
        status == .completed
    }

    func timeRemaining(at date: Date = Date()) -> Int {
        switch status {
        case .running:
            guard let phaseEndDate else { return 0 }
            return max(0, Int(ceil(phaseEndDate.timeIntervalSince(date))))
        case .ready, .paused:
            return max(0, Int(ceil(pausedRemaining)))
        case .completed:
            return 0
        }
    }

    /// Advances through every elapsed phase from absolute wall-clock dates. This
    /// remains accurate even when iOS suspends every process in the application.
    func resolved(at date: Date = Date()) -> SharedTimerSnapshot {
        guard status == .running else { return self }

        var result = self
        var safetyCounter = 0

        while result.status == .running,
              let endDate = result.phaseEndDate,
              date >= endDate,
              safetyCounter < 256 {
            safetyCounter += 1

            switch result.phase {
            case .work:
                if result.currentRound >= result.configuration.totalRounds {
                    result.status = .completed
                    result.phaseEndDate = nil
                    result.pausedRemaining = 0
                } else if result.configuration.breakDuration > 0 {
                    result.phase = .rest
                    result.phaseEndDate = endDate.addingTimeInterval(
                        TimeInterval(result.configuration.breakDuration)
                    )
                    result.pausedRemaining = TimeInterval(result.configuration.breakDuration)
                } else {
                    result.currentRound += 1
                    result.phase = .work
                    result.phaseEndDate = endDate.addingTimeInterval(
                        TimeInterval(result.configuration.roundDuration)
                    )
                    result.pausedRemaining = TimeInterval(result.configuration.roundDuration)
                }
            case .rest:
                result.currentRound += 1
                result.phase = .work
                result.phaseEndDate = endDate.addingTimeInterval(
                    TimeInterval(result.configuration.roundDuration)
                )
                result.pausedRemaining = TimeInterval(result.configuration.roundDuration)
            }
        }

        return result
    }

    func applying(_ action: SharedTimerAction, at date: Date = Date()) -> SharedTimerSnapshot {
        var result = resolved(at: date)

        switch action {
        case .start:
            guard result.status == .ready || result.status == .paused else { return result }
            result.status = .running
            result.phaseEndDate = date.addingTimeInterval(max(0.01, result.pausedRemaining))
        case .pause:
            guard result.status == .running, let endDate = result.phaseEndDate else { return result }
            result.pausedRemaining = max(0, endDate.timeIntervalSince(date))
            result.phaseEndDate = nil
            result.status = .paused
        case .reset:
            result = .ready(configuration: result.configuration, at: date)
            return result
        case .setRunning(let shouldRun):
            return result.applying(shouldRun ? .start : .pause, at: date)
        }

        result.mutationID = UUID()
        result.modifiedAt = date
        return result
    }

    func replacingConfiguration(
        _ configuration: SharedTimerConfiguration,
        at date: Date = Date()
    ) -> SharedTimerSnapshot {
        .ready(configuration: configuration, at: date)
    }

    func isNewer(than other: SharedTimerSnapshot) -> Bool {
        if modifiedAt != other.modifiedAt {
            return modifiedAt > other.modifiedAt
        }
        return mutationID.uuidString > other.mutationID.uuidString
    }

    /// Returns the phase boundaries used by WidgetKit and local notifications.
    func futureEvents(after date: Date = Date(), limit: Int = 60) -> [SharedTimerEvent] {
        var cursor = resolved(at: date)
        guard cursor.status == .running else { return [] }

        var events: [SharedTimerEvent] = []
        var safetyCounter = 0

        while cursor.status == .running,
              let endDate = cursor.phaseEndDate,
              events.count < limit,
              safetyCounter < 256 {
            safetyCounter += 1

            if cursor.phase == .work {
                let warningDate = endDate.addingTimeInterval(-10)
                if warningDate > date.addingTimeInterval(0.5), events.count < limit {
                    events.append(
                        SharedTimerEvent(
                            date: warningDate,
                            kind: .warning,
                            round: cursor.currentRound
                        )
                    )
                }
            }

            let next = cursor.resolved(at: endDate)
            let eventKind: SharedTimerEvent.Kind
            if next.status == .completed {
                eventKind = .completed
            } else if next.phase == .rest {
                eventKind = .restStarted
            } else {
                eventKind = .roundStarted
            }

            if events.count < limit {
                events.append(
                    SharedTimerEvent(
                        date: endDate,
                        kind: eventKind,
                        round: next.currentRound
                    )
                )
            }
            cursor = next
        }

        return events.sorted { $0.date < $1.date }
    }
}

struct SharedTimerEvent: Equatable, Sendable {
    enum Kind: Equatable, Sendable {
        case warning
        case restStarted
        case roundStarted
        case completed
    }

    var date: Date
    var kind: Kind
    var round: Int
}

enum SharedTimerRepository {
    static let appGroupIdentifier = "group.com.discomedia.AbsoluteTimer"
    private static let stateKey = "sharedTimerSnapshot.v1"

    private static var defaults: UserDefaults {
        UserDefaults(suiteName: appGroupIdentifier) ?? .standard
    }

    static func load() -> SharedTimerSnapshot? {
        guard let data = defaults.data(forKey: stateKey) else { return nil }
        return try? JSONDecoder().decode(SharedTimerSnapshot.self, from: data)
    }

    @discardableResult
    static func save(_ snapshot: SharedTimerSnapshot) -> SharedTimerSnapshot {
        if let data = try? JSONEncoder().encode(snapshot) {
            defaults.set(data, forKey: stateKey)
        }
        NotificationCenter.default.post(name: .sharedTimerDidChange, object: snapshot)
        return snapshot
    }

    @discardableResult
    static func perform(
        _ action: SharedTimerAction,
        fallback: SharedTimerConfiguration = .standardBoxing,
        at date: Date = Date()
    ) -> SharedTimerSnapshot {
        let current = load() ?? .ready(configuration: fallback, at: date)
        return save(current.applying(action, at: date))
    }

    @discardableResult
    static func acceptRemote(_ snapshot: SharedTimerSnapshot) -> Bool {
        if let current = load(), !snapshot.isNewer(than: current) {
            return false
        }
        save(snapshot)
        return true
    }
}

extension Notification.Name {
    static let sharedTimerDidChange = Notification.Name("SharedTimerDidChange")
}
