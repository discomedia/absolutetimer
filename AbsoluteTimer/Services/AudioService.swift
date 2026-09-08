//
//  AudioService.swift
//  AbsoluteTimer
//
//  Created by Dana Hooshmand on 15/11/2025.
//

import AVFoundation
import Foundation
import Combine

/// Plays the same bundled cues used by background local notifications.
final class AudioService: NSObject, ObservableObject, AVAudioPlayerDelegate {
    let objectWillChange = ObservableObjectPublisher()

    /// Configure audio session for playback/mix to allow TTS + system sounds while respecting other audio.
    private var player: AVAudioPlayer?

    override init() {
        super.init()
        setupAudioSession()
    }

    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }

    private func play(resource: String) {
        guard AppSettings.soundEnabled,
              let url = Bundle.main.url(forResource: resource, withExtension: "wav") else { return }

        do {
            try AVAudioSession.sharedInstance().setActive(true)
            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            player.volume = 1
            player.prepareToPlay()
            player.play()
            self.player = player
        } catch {
            print("Failed to play \(resource) cue: \(error)")
        }
    }

    /// Round/break bell-like cue. Maps to a standard system sound.
    func playBell() {
        play(resource: "bell")
    }

    func playCountdown() {
        play(resource: "countdown")
    }

    func playStart() {
        play(resource: "start")
    }

    /// Warning cue before round end. Uses a different short tone.
    func playWarning() {
        play(resource: "warning-double")
    }
}
