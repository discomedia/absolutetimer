//
//  ProfilesViewModel.swift
//  AbsoluteTimer
//
//  Created by Dana Hooshmand on 15/11/2025.
//

import Foundation
import Combine

class ProfilesViewModel: ObservableObject {
    @Published var profiles: [TimerProfile] = []
    @Published var selectedProfile: TimerProfile?
    
    private let storage: ProfileStorage
    
    init(storage: ProfileStorage) {
        self.storage = storage
        loadProfiles()
    }
    
    func loadProfiles() {
        profiles = storage.profiles
        selectedProfile = storage.loadSelectedProfile()
    }
    
    func selectProfile(_ profile: TimerProfile) {
        selectedProfile = profile
        storage.saveSelectedProfile(profile.id)
    }
    
    func saveProfile(_ profile: TimerProfile) {
        storage.saveProfile(profile)
        loadProfiles()
    }
    
    func deleteProfile(_ profile: TimerProfile) {
        storage.deleteProfile(profile)
        loadProfiles()
        
        // If deleted profile was selected, select first available
        if selectedProfile?.id == profile.id {
            selectedProfile = profiles.first
            if let first = profiles.first {
                storage.saveSelectedProfile(first.id)
            }
        }
    }
    
    func createNewProfile() -> TimerProfile {
        return TimerProfile(
            name: "New Profile",
            roundDuration: 180,
            breakDuration: 60,
            totalRounds: 3,
            isDefault: false
        )
    }
}

