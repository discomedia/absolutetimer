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
    let phase: String
    let phaseSymbol: String
    
    var body: some View {
        VStack(spacing: 16) {
            Label(phase.uppercased(), systemImage: phaseSymbol)
                .font(.headline.weight(.bold))
                .tracking(1.5)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.black.opacity(0.18), in: Capsule())

            Text(TimeFormatter.formatTime(timeRemaining))
                .font(.system(size: 120, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.45)
                .frame(maxWidth: .infinity)
                .accessibilityLabel("\(timeRemaining / 60) minutes, \(timeRemaining % 60) seconds remaining")
            
            Text(TimeFormatter.formatRound(current: currentRound, total: totalRounds))
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
        }
    }
}

#Preview {
    ZStack {
        Color.green
        TimerDisplay(timeRemaining: 180, currentRound: 1, totalRounds: 12, phase: "Work", phaseSymbol: "figure.boxing")
    }
}
