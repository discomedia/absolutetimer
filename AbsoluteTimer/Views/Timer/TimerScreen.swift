//
//  TimerScreen.swift
//  AbsoluteTimer
//
//  Created by Dana Hooshmand on 15/11/2025.
//

import SwiftUI

struct TimerScreen: View {
    @StateObject var viewModel: TimerViewModel
    var onProfileChange: (TimerProfile) -> Void = { _ in }
    @State private var showingProfileSelector = false
    @State private var showingResetConfirmation = false
    
    var body: some View {
        ZStack {
            TimerBackground(
                isActive: viewModel.state.isActive,
                isRoundActive: viewModel.state.isRoundActive,
                isPaused: !viewModel.state.isActive && viewModel.state.hasStarted && !viewModel.state.isCompleted
            )
            
            VStack(spacing: 40) {
                Spacer()
                
                // Profile selector button
                Button(action: {
                    Haptics.shared.light()
                    showingProfileSelector = true
                }) {
                    HStack {
                        Text(viewModel.currentProfile.name)
                            .font(.headline)
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(20)
                }
                .disabled(viewModel.state.hasStarted)
                .opacity(viewModel.state.hasStarted ? 0.0 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: viewModel.state.hasStarted)
                
                // Timer display
                TimerDisplay(
                    timeRemaining: viewModel.state.timeRemaining,
                    currentRound: viewModel.state.currentRound,
                    totalRounds: viewModel.currentProfile.totalRounds,
                    phase: phaseLabel,
                    phaseSymbol: phaseSymbol
                )
                
                Spacer()
                
                // Controls
                TimerControls(
                    isActive: viewModel.state.isActive,
                    isCompleted: viewModel.state.isCompleted,
                    hasStarted: viewModel.state.hasStarted,
                    onStart: viewModel.start,
                    onPause: viewModel.pause,
                    onReset: requestReset
                )
                
                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $showingProfileSelector) {
            ProfileSelector(
                selectedProfile: viewModel.currentProfile,
                onSelect: { profile in
                    viewModel.updateProfile(profile)
                    onProfileChange(profile)
                    showingProfileSelector = false
                }
            )
        }
        .confirmationDialog(
            "Reset this workout?",
            isPresented: $showingResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("Reset Workout", role: .destructive, action: viewModel.reset)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your current round progress will be cleared.")
        }
        .preferredColorScheme(.dark)
    }

    private var phaseLabel: String {
        if viewModel.state.isCompleted { return "Complete" }
        if !viewModel.state.hasStarted { return "Ready" }
        if !viewModel.state.isActive { return "Paused" }
        return viewModel.state.isRoundActive ? "Work" : "Rest"
    }

    private var phaseSymbol: String {
        if viewModel.state.isCompleted { return "checkmark.circle.fill" }
        if !viewModel.state.hasStarted { return "timer" }
        if !viewModel.state.isActive { return "pause.fill" }
        return viewModel.state.isRoundActive ? "figure.boxing" : "heart.fill"
    }

    private func requestReset() {
        if viewModel.state.hasStarted && !viewModel.state.isCompleted {
            showingResetConfirmation = true
        } else {
            viewModel.reset()
        }
    }
}

#Preview {
    TimerScreen(
        viewModel: TimerViewModel(
            profile: DefaultProfiles.profiles[0],
            audioService: AudioService(),
            speechService: SpeechService()
        )
    )
    .environmentObject(ProfileStorage())
}
