//
//  TimerState.swift
//  AbsoluteTimer
//
//  Created by Dana Hooshmand on 15/11/2025.
//

import Foundation

struct TimerState {
    var currentRound: Int = 1
    var timeRemaining: Int = 0
    var isActive: Bool = false
    var isRoundActive: Bool = true
    var isCompleted: Bool = false
    var hasStarted: Bool = false
    
    mutating func reset(roundDuration: Int) {
        currentRound = 1
        timeRemaining = roundDuration
        isActive = false
        isRoundActive = true
        isCompleted = false
        hasStarted = false
    }
}
