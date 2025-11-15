//
//  AudioService.swift
//  AbsoluteTimer
//
//  Created by Dana Hooshmand on 15/11/2025.
//

import AVFoundation
import Foundation
import Combine

class AudioService: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    
    init() {
        // All stored properties are initialized above; safe to use self now
        setupAudioSession()
        loadSounds()
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
    
    private func loadSounds() {
        loadSound(named: "bell", withExtension: "wav")
        loadSound(named: "warning", withExtension: "wav")
    }
    
    private func loadSound(named name: String, withExtension ext: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            print("Could not find sound file: \(name).\(ext)")
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            audioPlayers[name] = player
        } catch {
            print("Could not load sound file \(name): \(error)")
        }
    }
    
    func playSound(_ soundName: String) {
        audioPlayers[soundName]?.play()
    }
    
    func playBell() {
        playSound("bell")
    }
    
    func playWarning() {
        playSound("warning")
    }
}
