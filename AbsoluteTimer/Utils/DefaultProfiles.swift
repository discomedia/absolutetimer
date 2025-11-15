//
//  DefaultProfiles.swift
//  AbsoluteTimer
//
//  Created by Dana Hooshmand on 15/11/2025.
//

import Foundation

struct DefaultProfiles {
    static let profiles: [TimerProfile] = [
        TimerProfile(
            name: "Standard Boxing",
            roundDuration: 180,
            breakDuration: 60,
            totalRounds: 12,
            isDefault: true
        ),
        TimerProfile(
            name: "Standard MMA",
            roundDuration: 300,
            breakDuration: 60,
            totalRounds: 5,
            isDefault: true
        ),
        TimerProfile(
            name: "EMOM",
            roundDuration: 60,
            breakDuration: 0,
            totalRounds: 20,
            isDefault: true
        ),
        TimerProfile(
            name: "E2MOM",
            roundDuration: 120,
            breakDuration: 0,
            totalRounds: 10,
            isDefault: true
        )
    ]
}
