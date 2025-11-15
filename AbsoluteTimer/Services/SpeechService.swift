//
//  SpeechService.swift
//  AbsoluteTimer
//
//  Created by Dana Hooshmand on 15/11/2025.
//

import AVFoundation
import Foundation
import Combine

class SpeechService: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()
    
    
    private let synthesizer = AVSpeechSynthesizer()
    
    func announce(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        utterance.volume = 1.0
        
        synthesizer.speak(utterance)
    }
    
    func announceRound(_ round: Int, isFinal: Bool = false) {
        if isFinal {
            announce("Final Round")
        } else {
            announce("Round \(round)")
        }
    }
    
    func announceBreak() {
        announce("Break")
    }
    
    func announceTime() {
        announce("Time")
    }
}
