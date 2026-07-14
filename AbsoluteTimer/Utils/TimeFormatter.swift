//
//  TimeFormatter.swift
//  AbsoluteTimer
//
//  Created by Dana Hooshmand on 15/11/2025.
//

import Foundation

struct TimeFormatter {
    static func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
    
    static func formatRound(current: Int, total: Int) -> String {
        return "Round \(current) of \(total)"
    }

    static func formatDuration(_ seconds: Int) -> String {
        if seconds == 0 { return "No" }

        let minutes = seconds / 60
        let remainingSeconds = seconds % 60

        if minutes == 0 { return "\(remainingSeconds) sec" }
        if remainingSeconds == 0 { return "\(minutes) min" }
        return "\(minutes)m \(remainingSeconds)s"
    }
}
