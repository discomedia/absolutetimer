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
    
    init() {
        AppSettings.registerDefaults()
        loadSettings()
    }
    
    func loadSettings() {
        soundEnabled = AppSettings.soundEnabled
        speechEnabled = AppSettings.speechEnabled
        hapticsEnabled = AppSettings.hapticsEnabled
    }
    
    func saveSettings() {
        UserDefaults.standard.set(soundEnabled, forKey: AppSettings.soundKey)
        UserDefaults.standard.set(speechEnabled, forKey: AppSettings.speechKey)
        UserDefaults.standard.set(hapticsEnabled, forKey: AppSettings.hapticsKey)
    }
}
