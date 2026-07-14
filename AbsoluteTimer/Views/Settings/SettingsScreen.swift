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

    private let privacyURL = URL(string: "https://discomedia.co/privacy")!
    private let supportURL = URL(string: "https://discomedia.co/support")!

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
                        Text(appVersion)
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("App")
                        Spacer()
                        Text("Absolute Timer")
                            .foregroundColor(.secondary)
                    }

                    Text("Training timer only. Not medical, safety, or coaching advice.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                Section("Support") {
                    Link("Support", destination: supportURL)
                    Link("Privacy Policy", destination: privacyURL)
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

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
    }
}

#Preview {
    SettingsScreen()
}
