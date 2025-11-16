//
//  TimerBackground.swift
//  AbsoluteTimer
//
//  Created by Dana Hooshmand on 15/11/2025.
//

import SwiftUI

struct TimerBackground: View {
    let isActive: Bool
    let isRoundActive: Bool
    let isPaused: Bool
    
    var backgroundColor: Color {
        if isPaused {
            // Paused state: yellow
            return Color(red: 0.96, green: 0.62, blue: 0.04) // #f59e0b
        }
        if !isActive {
            // Idle before start or after reset/completion
            return .black
        }
        // Running
        return isRoundActive ? Color(red: 0.13, green: 0.77, blue: 0.37) : Color(red: 0.86, green: 0.15, blue: 0.15)
    }
    
    var body: some View {
        backgroundColor
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.5), value: backgroundColor)
    }
}

#Preview {
    VStack {
        TimerBackground(isActive: false, isRoundActive: true, isPaused: false)
        TimerBackground(isActive: true, isRoundActive: true, isPaused: false)
        TimerBackground(isActive: true, isRoundActive: false, isPaused: false)
        TimerBackground(isActive: true, isRoundActive: true, isPaused: true)
    }
}
