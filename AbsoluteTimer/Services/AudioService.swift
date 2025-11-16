//
//  AudioService.swift
//  AbsoluteTimer
//
//  Created by Dana Hooshmand on 15/11/2025.
//

import AVFoundation
import Foundation
import Combine
import AudioToolbox

/// AudioService provides non-verbal cues using system-provided capabilities only.
/// - No bundled audio files are used.
/// - Prefers system sounds when available; otherwise, falls back to haptics.
final class AudioService: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()

    /// Configure audio session for playback/mix to allow TTS + system sounds while respecting other audio.
    init() {
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

    // MARK: - System Cues

    /// Attempts to play a system sound by ID. If unavailable, does nothing (TimerViewModel may additionally trigger haptics).
    private func playSystemSound(id: SystemSoundID) {
        AudioServicesPlaySystemSound(id)
    }

    /// Round/break bell-like cue. Maps to a standard system sound.
    func playBell() {
        // 1007 is a commonly available tri-tone style; adjust if needed.
        // Note: System sound availability can vary; this is best-effort.
        playSystemSound(id: 1007)
    }

    /// Warning cue before round end. Uses a different short tone.
    func playWarning() {
        // 1057 is a short alert tone; choose a distinct ID from the bell.
        playSystemSound(id: 1057)
    }
}
