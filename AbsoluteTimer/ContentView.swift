//
//  ContentView.swift
//  AbsoluteTimer
//
//  Created by Dana Hooshmand on 15/11/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var profileStorage: ProfileStorage
    @EnvironmentObject var audioService: AudioService
    @EnvironmentObject var speechService: SpeechService
    
    @State private var showingSettings = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let selectedProfile = profileStorage.loadSelectedProfile() {
                TimerScreen(
                    viewModel: TimerViewModel(
                        profile: selectedProfile,
                        audioService: audioService,
                        speechService: speechService
                    ),
                    onProfileChange: { profileStorage.saveSelectedProfile($0.id) }
                )
            } else {
                // Fallback if no profile is selected
                TimerScreen(
                    viewModel: TimerViewModel(
                        profile: DefaultProfiles.profiles[0],
                        audioService: audioService,
                        speechService: speechService
                    ),
                    onProfileChange: { profileStorage.saveSelectedProfile($0.id) }
                )
            }
            
            // Settings button overlay
            Button(action: {
                Haptics.shared.light()
                showingSettings = true
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.7))
                    .padding()
            }
            .accessibilityLabel("Settings")
            .frame(minWidth: 44, minHeight: 44)
            .sheet(isPresented: $showingSettings) {
                SettingsScreen()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ProfileStorage())
        .environmentObject(AudioService())
        .environmentObject(SpeechService())
}
