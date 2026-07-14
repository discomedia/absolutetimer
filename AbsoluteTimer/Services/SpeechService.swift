//
//  SpeechService.swift
//  AbsoluteTimer
//
//  Created by Dana Hooshmand on 15/11/2025.
//

import AVFoundation
import Foundation
import Combine

final class SpeechService: NSObject, ObservableObject {
    let objectWillChange = ObservableObjectPublisher()

    private let synthesizer = AVSpeechSynthesizer()

    // User-tunable defaults
    private(set) var voice: AVSpeechSynthesisVoice? = nil
    private(set) var rate: Float = AVSpeechUtteranceDefaultSpeechRate
    private(set) var pitch: Float = 1.0
    private(set) var volume: Float = 1.0

    override init() {
        super.init()
        synthesizer.delegate = self
        configureDefaults()
    }

    private func configureDefaults() {
        // Attempt to choose a system voice matching the current locale.
        // If enumeration fails or returns empty, fall back to default (nil voice).
        let preferredLocale = Locale.current.identifier
        if let match = AVSpeechSynthesisVoice(language: preferredLocale) ?? AVSpeechSynthesisVoice(language: Locale.current.language.languageCode?.identifier ?? "en-US") {
            self.voice = match
        } else {
            // If the above fails, leave voice as nil to use system default.
            self.voice = nil
        }

        // A comfortable default rate for clarity.
        self.rate = 0.5
        self.pitch = 1.0
        self.volume = 1.0
    }

    // MARK: - Public API

    func setVoice(languageCode: String?) {
        if let code = languageCode, let v = AVSpeechSynthesisVoice(language: code) {
            self.voice = v
        } else {
            self.voice = nil
        }
    }

    func setRate(_ value: Float) { self.rate = value }
    func setPitch(_ value: Float) { self.pitch = value }
    func setVolume(_ value: Float) { self.volume = value }

    func announce(_ text: String) {
        guard AppSettings.speechEnabled else { return }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = voice
        utterance.rate = rate
        utterance.pitchMultiplier = pitch
        utterance.volume = volume
        synthesizer.speak(utterance)
    }

    func announceRound(_ round: Int, isFinal: Bool = false) {
        if isFinal {
            announce("Final Round")
        } else {
            announce("Round \(round)")
        }
    }

    func announceBreak() { announce("Break") }
    func announceTime() { announce("Time") }
}

extension SpeechService: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {}
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {}
}
