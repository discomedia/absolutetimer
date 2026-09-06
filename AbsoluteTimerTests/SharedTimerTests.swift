import XCTest

final class SharedTimerTests: XCTestCase {
    private let origin = Date(timeIntervalSince1970: 1_800_000_000)

    func testRunningTimerUsesAbsoluteElapsedTimeAcrossSuspension() {
        let configuration = makeConfiguration(round: 60, rest: 15, rounds: 3)
        let running = SharedTimerSnapshot.ready(configuration: configuration, at: origin)
            .applying(.start, at: origin)

        let afterBackgrounding = running.resolved(at: origin.addingTimeInterval(80))

        XCTAssertEqual(afterBackgrounding.currentRound, 2)
        XCTAssertEqual(afterBackgrounding.phase, .work)
        XCTAssertEqual(afterBackgrounding.timeRemaining(at: origin.addingTimeInterval(80)), 55)
        XCTAssertEqual(afterBackgrounding.status, .running)
    }

    func testTimerCompletesWhileApplicationIsSuspended() {
        let configuration = makeConfiguration(round: 10, rest: 5, rounds: 2)
        let running = SharedTimerSnapshot.ready(configuration: configuration, at: origin)
            .applying(.start, at: origin)

        let completed = running.resolved(at: origin.addingTimeInterval(25))

        XCTAssertEqual(completed.status, .completed)
        XCTAssertEqual(completed.timeRemaining(at: origin.addingTimeInterval(25)), 0)
        XCTAssertEqual(completed.currentRound, 2)
    }

    func testPauseAndResumePreserveSubsecondRemainder() {
        let configuration = makeConfiguration(round: 30, rest: 0, rounds: 1)
        let running = SharedTimerSnapshot.ready(configuration: configuration, at: origin)
            .applying(.start, at: origin)
        let pausedAt = origin.addingTimeInterval(12.25)
        let paused = running.applying(.pause, at: pausedAt)
        let resumedAt = origin.addingTimeInterval(120)
        let resumed = paused.applying(.start, at: resumedAt)

        XCTAssertEqual(paused.pausedRemaining, 17.75, accuracy: 0.001)
        XCTAssertEqual(resumed.phaseEndDate?.timeIntervalSince(resumedAt) ?? 0, 17.75, accuracy: 0.001)
    }

    func testZeroLengthBreakMovesDirectlyToNextRound() {
        let configuration = makeConfiguration(round: 10, rest: 0, rounds: 3)
        let running = SharedTimerSnapshot.ready(configuration: configuration, at: origin)
            .applying(.start, at: origin)

        let nextRound = running.resolved(at: origin.addingTimeInterval(10))

        XCTAssertEqual(nextRound.phase, .work)
        XCTAssertEqual(nextRound.currentRound, 2)
        XCTAssertEqual(nextRound.timeRemaining(at: origin.addingTimeInterval(10)), 10)
    }

    func testNotificationEventsHaveOneBoundaryAlertPerTransition() {
        let configuration = makeConfiguration(round: 30, rest: 10, rounds: 2)
        let running = SharedTimerSnapshot.ready(configuration: configuration, at: origin)
            .applying(.start, at: origin)

        let events = running.futureEvents(after: origin, limit: 20)

        XCTAssertEqual(events.map(\.kind), [.warning, .restStarted, .roundStarted, .warning, .completed])
        XCTAssertEqual(events.map(\.date.timeIntervalSince1970), [
            origin.timeIntervalSince1970 + 20,
            origin.timeIntervalSince1970 + 30,
            origin.timeIntervalSince1970 + 40,
            origin.timeIntervalSince1970 + 60,
            origin.timeIntervalSince1970 + 70
        ])
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
