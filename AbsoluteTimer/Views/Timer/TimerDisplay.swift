//
//  TimerDisplay.swift
//  AbsoluteTimer
//
//  Created by Dana Hooshmand on 15/11/2025.
//

import SwiftUI

struct TimerDisplay: View {
    let timeRemaining: Int
    let currentRound: Int
    let totalRounds: Int
    
    var body: some View {
        VStack(spacing: 20) {
            Text(TimeFormatter.formatTime(timeRemaining))
                .font(.system(size: 120, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .monospacedDigit()
            
            Text(TimeFormatter.formatRound(current: currentRound, total: totalRounds))
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
        }
    }
}

#Preview {
    ZStack {
        Color.green
        TimerDisplay(timeRemaining: 180, currentRound: 1, totalRounds: 12)
    }
}
