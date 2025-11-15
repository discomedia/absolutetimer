//
//  SettingsScreen.swift
//  AbsoluteTimer
//
//  Created by Dana Hooshmand on 15/11/2025.
//

import SwiftUI

struct SettingsScreen: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Audio & Haptics") {
                    Toggle("Sound Effects", isOn: $viewModel.soundEnabled)
                        .onChange(of: viewModel.soundEnabled) { oldValue, newValue in
                            viewModel.saveSettings()
                            Haptics.shared.light()
                        }
                    
                    Toggle("Voice Announcements", isOn: $viewModel.speechEnabled)
                        .onChange(of: viewModel.speechEnabled) { oldValue, newValue in
                            viewModel.saveSettings()
                            Haptics.shared.light()
                        }
                    
                    Toggle("Haptic Feedback", isOn: $viewModel.hapticsEnabled)
                        .onChange(of: viewModel.hapticsEnabled) { oldValue, newValue in
                            viewModel.saveSettings()
                            if viewModel.hapticsEnabled {
                                Haptics.shared.light()
                            }
                        }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("App")
                        Spacer()
                        Text("Absolute Timer")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Support") {
                    Link("Rate on App Store", destination: URL(string: "https://apps.apple.com")!)
                    Link("Report an Issue", destination: URL(string: "https://github.com")!)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsScreen()
}

