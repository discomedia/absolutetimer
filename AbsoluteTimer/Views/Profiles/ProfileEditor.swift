//
//  ProfileEditor.swift
//  AbsoluteTimer
//
//  Created by Dana Hooshmand on 15/11/2025.
//

import SwiftUI

struct ProfileEditor: View {
    @Environment(\.dismiss) private var dismiss
    @State var profile: TimerProfile
    let onSave: (TimerProfile) -> Void
    
    @State private var name: String
    @State private var roundDuration: Int
    @State private var breakDuration: Int
    @State private var totalRounds: Int
    
    init(profile: TimerProfile, onSave: @escaping (TimerProfile) -> Void) {
        self.profile = profile
        self.onSave = onSave
        _name = State(initialValue: profile.name)
        _roundDuration = State(initialValue: profile.roundDuration)
        _breakDuration = State(initialValue: profile.breakDuration)
        _totalRounds = State(initialValue: profile.totalRounds)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Profile Name") {
                    TextField("Name", text: $name)
                }
                
                Section("Timing") {
                    ProfileSliders(
                        roundDuration: $roundDuration,
                        breakDuration: $breakDuration,
                        totalRounds: $totalRounds
                    )
                    .padding(.vertical)
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Total Workout Time")
                            .font(.headline)
                        Text(totalWorkoutTime)
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle(profile.isDefault ? "View Profile" : profile.name.isEmpty ? "New Profile" : "Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                    }
                    .disabled(name.isEmpty || profile.isDefault)
                }
            }
        }
    }
    
    private var totalWorkoutTime: String {
        let totalSeconds = (roundDuration * totalRounds) + (breakDuration * (totalRounds - 1))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return "\(minutes)m \(seconds)s"
    }
    
    private func saveProfile() {
        var updatedProfile = profile
        updatedProfile.name = name
        updatedProfile.roundDuration = roundDuration
        updatedProfile.breakDuration = breakDuration
        updatedProfile.totalRounds = totalRounds
        
        Haptics.shared.success()
        onSave(updatedProfile)
        dismiss()
    }
}

#Preview {
    ProfileEditor(
        profile: TimerProfile(
            name: "Test Profile",
            roundDuration: 180,
            breakDuration: 60,
            totalRounds: 12,
            isDefault: false
        ),
        onSave: { _ in }
    )
}
