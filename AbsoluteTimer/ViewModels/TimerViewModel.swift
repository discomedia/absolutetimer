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
    private var snapshot: SharedTimerSnapshot
    private var lastRefreshDate = Date()
    
    init(profile: TimerProfile, audioService: AudioService, speechService: SpeechService) {
        self.audioService = audioService
        self.speechService = speechService
        let initial = SharedTimerRepository.load() ?? .ready(
            configuration: Self.configuration(from: profile)
        )
        self.snapshot = initial
        self.currentProfile = Self.profile(from: initial.configuration, fallback: profile)
        publish(initial.resolved())

        if SharedTimerRepository.load() == nil {
            SharedTimerRepository.save(initial)
        }

        WatchConnectivityBridge.shared.activate { [weak self] _ in
            self?.refresh(playCues: false)
        }

        startTimer()
    }
    
    func updateProfile(_ profile: TimerProfile) {
        currentProfile = profile
        commit(snapshot.replacingConfiguration(Self.configuration(from: profile)))
    }
    
    func start() {
        let wasReady = snapshot.resolved().status == .ready
        let updated = snapshot.applying(.start)
        guard updated != snapshot else { return }

        commit(updated)
        if wasReady {
            audioService.playBell()
            speechService.announceRound(state.currentRound, isFinal: state.currentRound == currentProfile.totalRounds)
        }
    }
    
    func pause() {
        commit(snapshot.applying(.pause))
    }
    
    func reset() {
        commit(snapshot.applying(.reset))
    }

    func sceneBecameActive() {
        lastRefreshDate = Date()
        refresh(playCues: false)
        Task { await SharedTimerNotifications.schedule(snapshot.resolved()) }
    }
    
    private func startTimer() {
        timerCancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.refresh(playCues: true)
            }
    }
    
    private func refresh(playCues: Bool) {
        let now = Date()
        let previous = snapshot.resolved(at: lastRefreshDate)

        if let stored = SharedTimerRepository.load(), stored.mutationID != snapshot.mutationID {
            snapshot = stored
            currentProfile = Self.profile(from: stored.configuration, fallback: currentProfile)
        }

        let current = snapshot.resolved(at: now)
        let refreshWasContinuous = now.timeIntervalSince(lastRefreshDate) < 0.75
        if playCues, refreshWasContinuous, UIApplication.shared.applicationState == .active {
            playForegroundCues(from: previous, to: current)
        }

        publish(current, at: now)
        lastRefreshDate = now
    }

    private func commit(_ updated: SharedTimerSnapshot) {
        snapshot = SharedTimerRepository.save(updated)
        currentProfile = Self.profile(from: updated.configuration, fallback: currentProfile)
        publish(updated.resolved())
        UIApplication.shared.isIdleTimerDisabled = updated.status == .running
        WatchConnectivityBridge.shared.send(updated)

        if updated.status == .running {
            Task { await SharedTimerNotifications.requestAuthorizationAndSchedule(updated) }
        } else {
            SharedTimerNotifications.cancel()
        }
    }

    private func publish(_ snapshot: SharedTimerSnapshot, at date: Date = Date()) {
        let resolved = snapshot.resolved(at: date)
        state.currentRound = resolved.currentRound
        state.timeRemaining = resolved.timeRemaining(at: date)
        state.isActive = resolved.status == .running
        state.isRoundActive = resolved.phase == .work
        state.isCompleted = resolved.status == .completed
        state.hasStarted = resolved.status != .ready
        UIApplication.shared.isIdleTimerDisabled = resolved.status == .running
    }

    private func playForegroundCues(from previous: SharedTimerSnapshot, to current: SharedTimerSnapshot) {
        if previous.status == .running,
           previous.phase == .work,
           current.phase == .work,
           previous.currentRound == current.currentRound,
           previous.timeRemaining(at: lastRefreshDate) > 10,
           current.timeRemaining() <= 10 {
            audioService.playWarning()
            Haptics.shared.warning()
        }

        guard previous.status == .running,
              (previous.phase != current.phase ||
               previous.currentRound != current.currentRound ||
               current.status == .completed) else { return }

        audioService.playBell()

        if current.status == .completed {
            speechService.announceTime()
            Haptics.shared.success()
            SharedTimerNotifications.cancel()
        } else if current.phase == .rest {
            speechService.announceBreak()
            Haptics.shared.heavy()
        } else {
            speechService.announceRound(
                current.currentRound,
                isFinal: current.currentRound == current.configuration.totalRounds
            )
            Haptics.shared.medium()
        }
    }

    private static func configuration(from profile: TimerProfile) -> SharedTimerConfiguration {
        SharedTimerConfiguration(
            profileID: profile.id,
            profileName: profile.name,
            roundDuration: profile.roundDuration,
            breakDuration: profile.breakDuration,
            totalRounds: profile.totalRounds
        )
    }

    private static func profile(from configuration: SharedTimerConfiguration, fallback: TimerProfile) -> TimerProfile {
        TimerProfile(
            id: configuration.profileID,
            name: configuration.profileName,
            roundDuration: configuration.roundDuration,
            breakDuration: configuration.breakDuration,
            totalRounds: configuration.totalRounds,
            isDefault: fallback.id == configuration.profileID ? fallback.isDefault : false
        )
    }
}
