import SwiftUI

struct WatchTimerView: View {
    @EnvironmentObject private var model: WatchTimerModel

    private var snapshot: SharedTimerSnapshot {
        model.snapshot.resolved()
    }

    var body: some View {
        VStack(spacing: 8) {
            Text(snapshot.configuration.profileName)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Text(phaseLabel)
                .font(.headline)
                .foregroundStyle(phaseColor)

            TimelineView(.periodic(from: .now, by: 0.25)) { context in
                let current = model.snapshot.resolved(at: context.date)
                Text(current.status == .countdown ? "\(current.timeRemaining(at: context.date))" : format(current.timeRemaining(at: context.date)))
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .minimumScaleFactor(0.6)
            }

            Text("Round \(snapshot.currentRound) of \(snapshot.configuration.totalRounds)")
                .font(.caption)

            HStack(spacing: 12) {
                Button(action: model.toggle) {
                    Image(systemName: snapshot.isActive ? "pause.fill" : "play.fill")
                }
                .tint(snapshot.isActive ? .orange : .green)
                .accessibilityLabel(snapshot.isActive ? "Pause" : "Start")

                Button(action: model.reset) {
                    Image(systemName: "arrow.counterclockwise")
                }
                .tint(.gray)
                .accessibilityLabel("Reset")
            }
        }
        .padding(.horizontal, 4)
    }

    private var phaseLabel: String {
        switch snapshot.status {
        case .ready: "Ready"
        case .countdown: "Get Ready"
        case .paused: "Paused"
        case .completed: "Complete"
        case .running: snapshot.phase == .work ? "Work" : "Rest"
        }
    }

    private var phaseColor: Color {
        if snapshot.status == .countdown { return .blue }
        guard snapshot.status == .running else { return .secondary }
        return snapshot.phase == .work ? .green : .red
    }

    private func format(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}
