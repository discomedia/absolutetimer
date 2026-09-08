import XCTest

final class SharedTimerTests: XCTestCase {
    private let origin = Date(timeIntervalSince1970: 1_800_000_000)

    func testRunningTimerUsesAbsoluteElapsedTimeAcrossSuspension() {
        let configuration = makeConfiguration(round: 60, rest: 15, rounds: 3)
        let running = SharedTimerSnapshot.ready(configuration: configuration, at: origin)
            .applying(.start, at: origin)

        let afterBackgrounding = running.resolved(at: origin.addingTimeInterval(85))

        XCTAssertEqual(afterBackgrounding.currentRound, 2)
        XCTAssertEqual(afterBackgrounding.phase, .work)
        XCTAssertEqual(afterBackgrounding.timeRemaining(at: origin.addingTimeInterval(85)), 55)
        XCTAssertEqual(afterBackgrounding.status, .running)
    }

    func testTimerCompletesWhileApplicationIsSuspended() {
        let configuration = makeConfiguration(round: 10, rest: 5, rounds: 2)
        let running = SharedTimerSnapshot.ready(configuration: configuration, at: origin)
            .applying(.start, at: origin)

        let completed = running.resolved(at: origin.addingTimeInterval(30))

        XCTAssertEqual(completed.status, .completed)
        XCTAssertEqual(completed.timeRemaining(at: origin.addingTimeInterval(30)), 0)
        XCTAssertEqual(completed.currentRound, 2)
    }

    func testPauseAndResumePreserveSubsecondRemainder() {
        let configuration = makeConfiguration(round: 30, rest: 0, rounds: 1)
        let running = SharedTimerSnapshot.ready(configuration: configuration, at: origin)
            .applying(.start, at: origin)
        let active = running.resolved(at: origin.addingTimeInterval(5))
        let pausedAt = origin.addingTimeInterval(17.25)
        let paused = active.applying(.pause, at: pausedAt)
        let resumedAt = origin.addingTimeInterval(120)
        let resumed = paused.applying(.start, at: resumedAt)

        XCTAssertEqual(paused.pausedRemaining, 17.75, accuracy: 0.001)
        XCTAssertEqual(resumed.phaseEndDate?.timeIntervalSince(resumedAt) ?? 0, 17.75, accuracy: 0.001)
    }

    func testZeroLengthBreakMovesDirectlyToNextRound() {
        let configuration = makeConfiguration(round: 10, rest: 0, rounds: 3)
        let running = SharedTimerSnapshot.ready(configuration: configuration, at: origin)
            .applying(.start, at: origin)

        let nextRound = running.resolved(at: origin.addingTimeInterval(15))

        XCTAssertEqual(nextRound.phase, .work)
        XCTAssertEqual(nextRound.currentRound, 2)
        XCTAssertEqual(nextRound.timeRemaining(at: origin.addingTimeInterval(15)), 10)
    }

    func testNotificationEventsHaveOneBoundaryAlertPerTransition() {
        let configuration = makeConfiguration(round: 30, rest: 10, rounds: 2)
        let running = SharedTimerSnapshot.ready(configuration: configuration, at: origin)
            .applying(.start, at: origin)

        let events = running.futureEvents(after: origin, limit: 20)

        XCTAssertEqual(events.map(\.kind), [.countdownTick(2), .countdownTick(1), .roundStarted, .warning, .restStarted, .roundStarted, .warning, .completed])
        XCTAssertEqual(events.map(\.date.timeIntervalSince1970), [
            origin.timeIntervalSince1970 + 3,
            origin.timeIntervalSince1970 + 4,
            origin.timeIntervalSince1970 + 5,
            origin.timeIntervalSince1970 + 25,
            origin.timeIntervalSince1970 + 35,
            origin.timeIntervalSince1970 + 45,
            origin.timeIntervalSince1970 + 65,
            origin.timeIntervalSince1970 + 75
        ])
    }

    func testNewSessionCountsDownForFiveSecondsBeforeStartingRound() {
        let configuration = makeConfiguration(round: 30, rest: 10, rounds: 2)
        let countdown = SharedTimerSnapshot.ready(configuration: configuration, at: origin)
            .applying(.start, at: origin)

        XCTAssertEqual(countdown.status, .countdown)
        XCTAssertEqual(countdown.timeRemaining(at: origin), 5)
        XCTAssertEqual(countdown.resolved(at: origin.addingTimeInterval(4)).status, .countdown)

        let started = countdown.resolved(at: origin.addingTimeInterval(5))
        XCTAssertEqual(started.status, .running)
        XCTAssertEqual(started.timeRemaining(at: origin.addingTimeInterval(5)), 30)
    }

    func testPausingCountdownCancelsSessionStart() {
        let configuration = makeConfiguration(round: 30, rest: 10, rounds: 2)
        let countdown = SharedTimerSnapshot.ready(configuration: configuration, at: origin)
            .applying(.start, at: origin)

        let cancelled = countdown.applying(.pause, at: origin.addingTimeInterval(2))

        XCTAssertEqual(cancelled.status, .ready)
        XCTAssertEqual(cancelled.timeRemaining(at: origin.addingTimeInterval(2)), 30)
    }

    func testFeedbackPreferencesPreserveActiveDeadline() {
        let configuration = makeConfiguration(round: 30, rest: 10, rounds: 2)
        let countdown = SharedTimerSnapshot.ready(configuration: configuration, at: origin)
            .applying(.start, at: origin)

        let updated = countdown.replacingPreferences(
            soundEnabled: false,
            hapticsEnabled: false,
            at: origin.addingTimeInterval(1)
        )

        XCTAssertEqual(updated.status, .countdown)
        XCTAssertEqual(updated.phaseEndDate, countdown.phaseEndDate)
        XCTAssertEqual(updated.configuration.soundEnabled, false)
        XCTAssertEqual(updated.configuration.hapticsEnabled, false)
    }

    func testOlderSavedConfigurationDecodesWithFeedbackDefaults() throws {
        let data = Data(
            """
            {
              "profileID": "4E82A9CF-26A6-4CC4-9955-B47671B1B711",
              "profileName": "Legacy",
              "roundDuration": 30,
              "breakDuration": 10,
              "totalRounds": 2
            }
            """.utf8
        )

        let configuration = try JSONDecoder().decode(SharedTimerConfiguration.self, from: data)

        XCTAssertNil(configuration.soundEnabled)
        XCTAssertNil(configuration.hapticsEnabled)
    }

    private func makeConfiguration(round: Int, rest: Int, rounds: Int) -> SharedTimerConfiguration {
        SharedTimerConfiguration(
            profileID: UUID(),
            profileName: "Test",
            roundDuration: round,
            breakDuration: rest,
            totalRounds: rounds
        )
    }
}
