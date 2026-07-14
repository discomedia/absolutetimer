//
//  AbsoluteTimerApp.swift
//  AbsoluteTimer
//
//  Created by Dana Hooshmand on 15/11/2025.
//

import SwiftUI

@main
struct AbsoluteTimerApp: App {
    @StateObject private var profileStorage = ProfileStorage()
    @StateObject private var audioService = AudioService()
    @StateObject private var speechService = SpeechService()

    init() {
        AppSettings.registerDefaults()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(profileStorage)
                .environmentObject(audioService)
                .environmentObject(speechService)
                .preferredColorScheme(.dark)
        }
    }
}
