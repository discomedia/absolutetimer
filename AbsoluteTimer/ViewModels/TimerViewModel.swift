//
//  TimerViewModel.swift
//  AbsoluteTimer
//
//  Created by Dana Hooshmand on 15/11/2025.
//

import Combine
import Foundation
import UIKit

class TimerViewModel: ObservableObject {
    @Published var state = TimerState()
    @Published var currentProfile: TimerProfile
    
    private var timerCancellable: AnyCancellable?
    private let audioService: AudioService
    private let speechService: SpeechService
    
    private var warningPlayed = false
    
    init(profile: TimerProfile, audioService: AudioService, speechService: SpeechService) {
        self.currentProfile = profile
        self.audioService = audioService
        self.speechService = speechService
        self.state.timeRemaining = profile.roundDuration
    }
    
    func updateProfile(_ profile: TimerProfile) {
        currentProfile = profile
        reset()
    }
    
    func start() {
        state.isActive = true
        UIApplication.shared.isIdleTimerDisabled = true
        
        if state.currentRound == 1 && state.timeRemaining == currentProfile.roundDuration {
            // First start
            audioService.playBell()
            speechService.announceRound(state.currentRound, isFinal: state.currentRound == currentProfile.totalRounds)
        }
        
        startTimer()
    }
    
    func pause() {
        state.isActive = false
        UIApplication.shared.isIdleTimerDisabled = false
        stopTimer()
    }
    
    func reset() {
        stopTimer()
        state.reset(roundDuration: currentProfile.roundDuration)
        warningPlayed = false
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    private func startTimer() {
        timerCancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }
    
    private func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
    
    private func tick() {
        guard state.isActive else { return }
        
        state.timeRemaining -= 1
        
        // Warning at 10 seconds
        if state.isRoundActive && state.timeRemaining == 10 && !warningPlayed {
            audioService.playWarning()
            Haptics.shared.warning()
            warningPlayed = true
        }
        
        if state.timeRemaining <= 0 {
            handleTimeEnd()
        }
    }
    
    private func handleTimeEnd() {
        if state.isRoundActive {
            // Round ended
            audioService.playBell()
            Haptics.shared.heavy()
            
            if state.currentRound < currentProfile.totalRounds {
                // Move to break
                state.isRoundActive = false
                state.timeRemaining = currentProfile.breakDuration
                warningPlayed = false
                
                if currentProfile.breakDuration > 0 {
                    speechService.announceBreak()
                } else {
                    // No break, move to next round immediately
                    handleTimeEnd()
                }
            } else {
                // Timer completed
                completeTimer()
            }
        } else {
            // Break ended
            audioService.playBell()
            Haptics.shared.medium()
            
            state.currentRound += 1
            state.isRoundActive = true
            state.timeRemaining = currentProfile.roundDuration
            warningPlayed = false
            
            speechService.announceRound(state.currentRound, isFinal: state.currentRound == currentProfile.totalRounds)
        }
    }
    
    private func completeTimer() {
        state.isCompleted = true
        state.isActive = false
        speechService.announceTime()
        Haptics.shared.success()
        UIApplication.shared.isIdleTimerDisabled = false
        stopTimer()
    }
}
