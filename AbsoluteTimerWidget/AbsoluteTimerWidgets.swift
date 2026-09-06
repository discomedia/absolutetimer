import AppIntents
import SwiftUI
import WidgetKit

@main
struct AbsoluteTimerWidgets: WidgetBundle {
    var body: some Widget {
        TimerStatusWidget()
        TimerRunningControl()
        TimerResetControl()
    }
}

struct TimerWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: SharedTimerSnapshot
}

struct TimerTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> TimerWidgetEntry {
        TimerWidgetEntry(
            date: Date(),
            snapshot: .ready(configuration: .standardBoxing)
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (TimerWidgetEntry) -> Void) {
        completion(
            TimerWidgetEntry(
                date: Date(),
                snapshot: SharedTimerRepository.load() ?? .ready(configuration: .standardBoxing)
            )
        )
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TimerWidgetEntry>) -> Void) {
        let now = Date()
        let snapshot = SharedTimerRepository.load() ?? .ready(configuration: .standardBoxing)
        var entries = [TimerWidgetEntry(date: now, snapshot: snapshot)]

        for event in snapshot.futureEvents(after: now) where event.kind != .warning {
            entries.append(TimerWidgetEntry(date: event.date, snapshot: snapshot))
        }

        let refreshDate = entries.last?.date.addingTimeInterval(1) ?? now.addingTimeInterval(60)
        completion(Timeline(entries: entries, policy: .after(refreshDate)))
    }
}

struct TimerStatusWidget: Widget {
    let kind = "AbsoluteTimer.Status"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TimerTimelineProvider()) { entry in
            TimerWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    TimerWidgetColors.background(for: entry.snapshot.resolved(at: entry.date))
                }
        }
        .configurationDisplayName("Absolute Timer")
        .description("See and control your current workout timer.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular])
    }
}

struct TimerWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: TimerWidgetEntry

    private var snapshot: SharedTimerSnapshot {
        entry.snapshot.resolved(at: entry.date)
    }

    var body: some View {
        switch family {
        case .accessoryCircular:
            VStack(spacing: 0) {
                Image(systemName: snapshot.phase == .work ? "figure.boxing" : "heart.fill")
                timerText.font(.caption2.monospacedDigit())
            }
        case .accessoryRectangular:
            HStack {
                VStack(alignment: .leading, spacing: 1) {
                    Text(phaseLabel).font(.caption.bold())
                    timerText.font(.headline.monospacedDigit())
                }
                Spacer()
                Text("\(snapshot.currentRound)/\(snapshot.configuration.totalRounds)")
                    .font(.caption2)
            }
        default:
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label(phaseLabel, systemImage: phaseSymbol)
                        .font(.caption.bold())
                    Spacer()
                    Text("Round \(snapshot.currentRound)/\(snapshot.configuration.totalRounds)")
                        .font(.caption2)
                }

                timerText
                    .font(.system(size: family == .systemMedium ? 44 : 36, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .minimumScaleFactor(0.7)

                HStack(spacing: 12) {
                    Button(intent: ToggleTimerIntent()) {
                        Label(snapshot.isActive ? "Pause" : "Start", systemImage: snapshot.isActive ? "pause.fill" : "play.fill")
                    }
                    .buttonStyle(.borderedProminent)

                    Button(intent: ResetTimerIntent()) {
                        Image(systemName: "arrow.counterclockwise")
                    }
                    .buttonStyle(.bordered)
                }
            }
            .foregroundStyle(.white)
        }
    }

    @ViewBuilder
    private var timerText: some View {
        if snapshot.status == .running, let endDate = snapshot.phaseEndDate {
            Text(endDate, style: .timer)
        } else {
            Text(format(snapshot.timeRemaining(at: entry.date)))
        }
    }

    private var phaseLabel: String {
        switch snapshot.status {
        case .ready: "Ready"
        case .paused: "Paused"
        case .completed: "Complete"
        case .running: snapshot.phase == .work ? "Work" : "Rest"
        }
    }

    private var phaseSymbol: String {
        switch snapshot.status {
        case .ready: "timer"
        case .paused: "pause.fill"
        case .completed: "checkmark.circle.fill"
        case .running: snapshot.phase == .work ? "figure.boxing" : "heart.fill"
        }
    }

    private func format(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}

enum TimerWidgetColors {
    static func background(for snapshot: SharedTimerSnapshot) -> Color {
        guard snapshot.status == .running else { return .black }
        return snapshot.phase == .work ? Color.green.opacity(0.8) : Color.red.opacity(0.8)
    }
}

struct TimerControlValueProvider: ControlValueProvider {
    var previewValue: Bool { false }

    func currentValue() async throws -> Bool {
        let snapshot = SharedTimerRepository.load() ?? .ready(configuration: .standardBoxing)
        return snapshot.resolved().status == .running
    }
}

struct TimerRunningControl: ControlWidget {
    static let kind = "AbsoluteTimer.RunningControl"

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: Self.kind, provider: TimerControlValueProvider()) { isRunning in
            ControlWidgetToggle(isOn: isRunning, action: SetTimerRunningIntent()) {
                Label("Timer", systemImage: isRunning ? "pause.circle.fill" : "play.circle.fill")
            } valueLabel: { value in
                Text(value ? "Running" : "Paused")
            }
        }
        .displayName("Absolute Timer")
        .description("Start or pause the current timer.")
    }
}

struct TimerResetControl: ControlWidget {
    static let kind = "AbsoluteTimer.ResetControl"

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: Self.kind) {
            ControlWidgetButton(action: ResetTimerIntent()) {
                Label("Reset Timer", systemImage: "arrow.counterclockwise")
            }
        }
        .displayName("Reset Timer")
        .description("Reset the current Absolute Timer workout.")
    }
}
