//
//  AppSettings.swift
//  AbsoluteTimer
//

import Foundation

enum AppSettings {
    static let soundKey = "soundEnabled"
    static let speechKey = "speechEnabled"
    static let hapticsKey = "hapticsEnabled"

    private static let registeredDefaults: Void = {
        UserDefaults.standard.register(defaults: [
            soundKey: true,
            speechKey: true,
            hapticsKey: true
        ])
    }()

    static func registerDefaults() {
        _ = registeredDefaults
    }

    static var soundEnabled: Bool {
        registerDefaults()
        return UserDefaults.standard.bool(forKey: soundKey)
    }

    static var speechEnabled: Bool {
        registerDefaults()
        return UserDefaults.standard.bool(forKey: speechKey)
    }

    static var hapticsEnabled: Bool {
        registerDefaults()
        return UserDefaults.standard.bool(forKey: hapticsKey)
    }
}
