//
//  TimerScreen.swift
//  AbsoluteTimer
//
//  Created by Dana Hooshmand on 15/11/2025.
//

import SwiftUI

struct TimerScreen: View {
    @StateObject var viewModel: TimerViewModel
    @State private var showingProfileSelector = false
    
    var body: some View {
        ZStack {
            TimerBackground(
                isActive: viewModel.state.isActive,
                isRoundActive: viewModel.state.isRoundActive
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
                .disabled(viewModel.state.isActive)
                .opacity(viewModel.state.isActive ? 0.5 : 1.0)
                
                // Timer display
                TimerDisplay(
                    timeRemaining: viewModel.state.timeRemaining,
                    currentRound: viewModel.state.currentRound,
                    totalRounds: viewModel.currentProfile.totalRounds
                )
                
                Spacer()
                
                // Controls
                TimerControls(
                    isActive: viewModel.state.isActive,
                    isCompleted: viewModel.state.isCompleted,
                    onStart: viewModel.start,
                    onPause: viewModel.pause,
                    onReset: viewModel.reset
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
                    showingProfileSelector = false
                }
            )
        }
        .preferredColorScheme(.dark)
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
}
