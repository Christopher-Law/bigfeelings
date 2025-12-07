//
//  UserDefaultsManager.swift
//  bigfeelings
//
//  Created by Christopher Law on 2025-12-07.
//

import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    
    private let selectedAgeKey = "selectedAge"
    private let completedStoriesKey = "completedStories"
    
    private init() {}
    
    func saveSelectedAge(_ ageRange: AgeRange) {
        UserDefaults.standard.set(ageRange.rawValue, forKey: selectedAgeKey)
    }
    
    func getSelectedAge() -> AgeRange? {
        guard let rawValue = UserDefaults.standard.string(forKey: selectedAgeKey),
              let ageRange = AgeRange(rawValue: rawValue) else {
            return nil
        }
        return ageRange
    }
    
    func clearSelectedAge() {
        UserDefaults.standard.removeObject(forKey: selectedAgeKey)
    }
    
    func markStoryCompleted(_ storyId: String) {
        var completed = getCompletedStories()
        if !completed.contains(storyId) {
            completed.append(storyId)
            UserDefaults.standard.set(completed, forKey: completedStoriesKey)
        }
    }
    
    func getCompletedStories() -> [String] {
        return UserDefaults.standard.stringArray(forKey: completedStoriesKey) ?? []
    }
    
    func isStoryCompleted(_ storyId: String) -> Bool {
        return getCompletedStories().contains(storyId)
    }
    
    func clearAllData() {
        UserDefaults.standard.removeObject(forKey: selectedAgeKey)
        UserDefaults.standard.removeObject(forKey: completedStoriesKey)
    }
}

