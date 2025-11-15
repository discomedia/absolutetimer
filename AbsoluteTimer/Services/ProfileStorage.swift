//
//  ProfileStorage.swift
//  AbsoluteTimer
//
//  Created by Dana Hooshmand on 15/11/2025.
//

import Foundation
import Combine

class ProfileStorage: ObservableObject {
    @Published var profiles: [TimerProfile] = []
    
    private let userProfilesKey = "userTimerProfiles"
    private let selectedProfileKey = "selectedProfileID"
    
    init() {
        loadProfiles()
    }
    
    func loadProfiles() {
        // Load default profiles
        var allProfiles = DefaultProfiles.profiles
        
        // Load user-created profiles
        if let data = UserDefaults.standard.data(forKey: userProfilesKey),
           let userProfiles = try? JSONDecoder().decode([TimerProfile].self, from: data) {
            allProfiles.append(contentsOf: userProfiles)
        }
        
        profiles = allProfiles
    }
    
    func saveProfile(_ profile: TimerProfile) {
        if profile.isDefault {
            return // Don't allow modifying default profiles
        }
        
        // Add or update profile
        if let index = profiles.firstIndex(where: { $0.id == profile.id }) {
            profiles[index] = profile
        } else {
            profiles.append(profile)
        }
        
        saveUserProfiles()
    }
    
    func deleteProfile(_ profile: TimerProfile) {
        guard !profile.isDefault else { return }
        
        profiles.removeAll { $0.id == profile.id }
        saveUserProfiles()
    }
    
    private func saveUserProfiles() {
        let userProfiles = profiles.filter { !$0.isDefault }
        if let data = try? JSONEncoder().encode(userProfiles) {
            UserDefaults.standard.set(data, forKey: userProfilesKey)
        }
    }
    
    func saveSelectedProfile(_ profileID: UUID) {
        UserDefaults.standard.set(profileID.uuidString, forKey: selectedProfileKey)
    }
    
    func loadSelectedProfile() -> TimerProfile? {
        guard let idString = UserDefaults.standard.string(forKey: selectedProfileKey),
              let id = UUID(uuidString: idString) else {
            return profiles.first // Return first profile as default
        }
        
        return profiles.first { $0.id == id } ?? profiles.first
    }
}
