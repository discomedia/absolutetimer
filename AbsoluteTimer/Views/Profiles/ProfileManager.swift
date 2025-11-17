//
//  ProfileManager.swift
//  AbsoluteTimer
//
//  Created by Dana Hooshmand on 15/11/2025.
//

import SwiftUI

struct ProfileManager: View {
    @StateObject private var storage = ProfileStorage()
    @Environment(\.dismiss) private var dismiss
    
    @State private var profileToEdit: TimerProfile?
    
    var body: some View {
        NavigationView {
            List {
                Section("Default Profiles") {
                    ForEach(storage.profiles.filter { $0.isDefault }) { profile in
                        ProfileManagerRow(profile: profile)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                profileToEdit = profile
                            }
                    }
                }
                
                Section("Custom Profiles") {
                    ForEach(storage.profiles.filter { !$0.isDefault }) { profile in
                        ProfileManagerRow(profile: profile)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                profileToEdit = profile
                            }
                    }
                    .onDelete(perform: deleteProfiles)
                }
            }
            .navigationTitle("Manage Profiles")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        let newProfile = TimerProfile(
                            name: "New Profile",
                            roundDuration: 180,
                            breakDuration: 60,
                            totalRounds: 3,
                            isDefault: false
                        )
                        profileToEdit = newProfile
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(item: $profileToEdit) { profile in
                ProfileEditor(profile: profile) { updatedProfile in
                    storage.saveProfile(updatedProfile)
                    storage.loadProfiles()
                }
            }
        }
    }
    
    private func deleteProfiles(at offsets: IndexSet) {
        let customProfiles = storage.profiles.filter { !$0.isDefault }
        for index in offsets {
            let profile = customProfiles[index]
            storage.deleteProfile(profile)
        }
    }
}

struct ProfileManagerRow: View {
    let profile: TimerProfile
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(profile.name)
                    .font(.headline)
                
                Text("\(profile.roundDuration)s rounds × \(profile.totalRounds) • \(profile.breakDuration)s break")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ProfileManager()
}
