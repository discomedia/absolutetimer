//
//  ProfileSelector.swift
//  AbsoluteTimer
//
//  Created by Dana Hooshmand on 15/11/2025.
//

import SwiftUI

struct ProfileSelector: View {
    @StateObject private var storage = ProfileStorage()
    let selectedProfile: TimerProfile
    let onSelect: (TimerProfile) -> Void
    
    @State private var showingProfileManager = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Default Profiles") {
                    ForEach(storage.profiles.filter { $0.isDefault }) { profile in
                        ProfileRow(profile: profile, isSelected: profile.id == selectedProfile.id)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                Haptics.shared.light()
                                onSelect(profile)
                            }
                    }
                }
                
                if !storage.profiles.filter({ !$0.isDefault }).isEmpty {
                    Section("Custom Profiles") {
                        ForEach(storage.profiles.filter { !$0.isDefault }) { profile in
                            ProfileRow(profile: profile, isSelected: profile.id == selectedProfile.id)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    Haptics.shared.light()
                                    onSelect(profile)
                                }
                        }
                    }
                }
            }
            .navigationTitle("Select Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingProfileManager = true
                    }) {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .sheet(isPresented: $showingProfileManager) {
                ProfileManager()
            }
        }
    }
}

struct ProfileRow: View {
    let profile: TimerProfile
    let isSelected: Bool
    
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
            
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
            }
        }
    }
}

#Preview {
    ProfileSelector(
        selectedProfile: DefaultProfiles.profiles[0],
        onSelect: { _ in }
    )
}
