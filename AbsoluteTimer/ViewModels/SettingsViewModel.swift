//
//  SettingsViewModel.swift
//  AbsoluteTimer
//
//  Created by Dana Hooshmand on 15/11/2025.
//

import Foundation
import Combine

class SettingsViewModel: ObservableObject {
    @Published var soundEnabled: Bool = true
    @Published var speechEnabled: Bool = true
    @Published var hapticsEnabled: Bool = true
    
    private let soundKey = "soundEnabled"
    private let speechKey = "speechEnabled"
    private let hapticsKey = "hapticsEnabled"
    
    init() {
        loadSettings()
    }
    
    func loadSettings() {
        soundEnabled = UserDefaults.standard.bool(forKey: soundKey)
        speechEnabled = UserDefaults.standard.bool(forKey: speechKey)
        hapticsEnabled = UserDefaults.standard.bool(forKey: hapticsKey)
        
        // Default to true if not set
        if !UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            soundEnabled = true
            speechEnabled = true
            hapticsEnabled = true
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            saveSettings()
        }
    }
    
    func saveSettings() {
        UserDefaults.standard.set(soundEnabled, forKey: soundKey)
        UserDefaults.standard.set(speechEnabled, forKey: speechKey)
        UserDefaults.standard.set(hapticsEnabled, forKey: hapticsKey)
    }
}
