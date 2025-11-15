//
//  TimerProfile.swift
//  AbsoluteTimer
//
//  Created by Dana Hooshmand on 15/11/2025.
//

import Foundation

struct TimerProfile: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var roundDuration: Int
    var breakDuration: Int
    var totalRounds: Int
    var isDefault: Bool
    
    init(id: UUID = UUID(), name: String, roundDuration: Int, breakDuration: Int, totalRounds: Int, isDefault: Bool = false) {
        self.id = id
        self.name = name
        self.roundDuration = roundDuration
        self.breakDuration = breakDuration
        self.totalRounds = totalRounds
        self.isDefault = isDefault
    }
}
