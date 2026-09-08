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
    private var settingsCancellable: AnyCancellable?
    private let audioService: AudioService
    private let speechService: SpeechService
    private var snapshot: SharedTimerSnapshot
    private var lastRefreshDate = Date()
    
    init(profile: TimerProfile, audioService: AudioService, speechService: SpeechService) {
        self.audioService = audioService
        self.speechService = speechService
        let persisted = SharedTimerRepository.load()
        let base = persisted ?? .ready(
            configuration: Self.configuration(from: profile)
        )
        let initial: SharedTimerSnapshot
        if base.configuration.soundEnabled != AppSettings.soundEnabled ||
            base.configuration.hapticsEnabled != AppSettings.hapticsEnabled {
            initial = base.replacingPreferences(
                soundEnabled: AppSettings.soundEnabled,
                hapticsEnabled: AppSettings.hapticsEnabled
            )
        } else {
            initial = base
        }
        self.snapshot = initial
        self.currentProfile = Self.profile(from: initial.configuration, fallback: profile)
        publish(initial.resolved())

        if persisted == nil || initial != base {
            SharedTimerRepository.save(initial)
        }

        WatchConnectivityBridge.shared.activate { [weak self] _ in
            self?.refresh(playCues: false)
        }

        settingsCancellable = NotificationCenter.default.publisher(for: .appSettingsDidChange)
            .sink { [weak self] _ in
                guard let self else { return }
                commit(
                    snapshot.replacingPreferences(
                        soundEnabled: AppSettings.soundEnabled,
                        hapticsEnabled: AppSettings.hapticsEnabled
                    )
                )
            }

        startTimer()
    }
    
    func updateProfile(_ profile: TimerProfile) {
        currentProfile = profile
        commit(snapshot.replacingConfiguration(Self.configuration(from: profile)))
    }
    
    func start() {
        let updated = snapshot.applying(.start)
        guard updated != snapshot else { return }

        commit(updated)
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
        UIApplication.shared.isIdleTimerDisabled = updated.isActive
        WatchConnectivityBridge.shared.send(updated)

        if updated.isActive {
            Task { await SharedTimerNotifications.requestAuthorizationAndSchedule(updated) }
        } else {
            SharedTimerNotifications.cancel()
        }
    }

    private func publish(_ snapshot: SharedTimerSnapshot, at date: Date = Date()) {
        let resolved = snapshot.resolved(at: date)
        state.currentRound = resolved.currentRound
        state.timeRemaining = resolved.timeRemaining(at: date)
        state.isActive = resolved.isActive
        state.isCountingDown = resolved.status == .countdown
        state.isRoundActive = resolved.phase == .work
        state.isCompleted = resolved.status == .completed
        state.hasStarted = resolved.status != .ready
        UIApplication.shared.isIdleTimerDisabled = resolved.isActive
    }

    private func playForegroundCues(from previous: SharedTimerSnapshot, to current: SharedTimerSnapshot) {
        if previous.status == .countdown {
            let previousRemaining = previous.timeRemaining(at: lastRefreshDate)
            let currentRemaining = current.timeRemaining()

            if current.status == .countdown {
                if previousRemaining > 2, currentRemaining <= 2 {
                    audioService.playCountdown()
                }
                if previousRemaining > 1, currentRemaining <= 1 {
                    audioService.playCountdown()
                }
            } else if current.status == .running {
                audioService.playStart()
                speechService.announceRound(
                    current.currentRound,
                    isFinal: current.currentRound == current.configuration.totalRounds
                )
                Haptics.shared.medium()
            }
        }

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

        if current.status == .completed {
            audioService.playBell()
            speechService.announceTime()
            Haptics.shared.success()
            SharedTimerNotifications.cancel()
        } else if current.phase == .rest {
            audioService.playBell()
            speechService.announceBreak()
            Haptics.shared.heavy()
        } else {
            audioService.playStart()
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
            totalRounds: profile.totalRounds,
            soundEnabled: AppSettings.soundEnabled,
            hapticsEnabled: AppSettings.hapticsEnabled
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
