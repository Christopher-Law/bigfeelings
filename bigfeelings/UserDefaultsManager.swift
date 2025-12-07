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
    private let quizSessionsKey = "quizSessions"
    
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
        UserDefaults.standard.removeObject(forKey: quizSessionsKey)
    }
    
    // MARK: - Quiz Session Management
    
    func saveQuizSession(_ session: QuizSession) {
        var sessions = getQuizSessions()
        // Remove old session with same ID if exists
        sessions.removeAll { $0.id == session.id }
        sessions.append(session)
        
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: quizSessionsKey)
        }
    }
    
    func getQuizSessions() -> [QuizSession] {
        guard let data = UserDefaults.standard.data(forKey: quizSessionsKey),
              let sessions = try? JSONDecoder().decode([QuizSession].self, from: data) else {
            return []
        }
        return sessions
    }
    
    func getQuizSessions(for ageRange: AgeRange) -> [QuizSession] {
        return getQuizSessions().filter { $0.ageRange == ageRange }
    }
    
    func getLatestQuizSession(for ageRange: AgeRange) -> QuizSession? {
        return getQuizSessions(for: ageRange)
            .sorted { $0.startDate > $1.startDate }
            .first
    }
}

