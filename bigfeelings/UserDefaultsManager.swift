//
//  UserDefaultsManager.swift
//  bigfeelings
//
//  Created by Christopher Law on 2025-12-07.
//

import Foundation
import os.log

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    
    private let logger = Logger(subsystem: "com.bigfeelings", category: "UserDefaultsManager")
    
    private let selectedAgeKey = "selectedAge"
    private let completedStoriesKey = "completedStories"
    private let quizSessionsKey = "quizSessions"
    private let childrenKey = "children"
    private let selectedChildIdKey = "selectedChildId"
    
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
    
    // Per-child story completion tracking
    private func completedStoriesKey(forChildId childId: String) -> String {
        return "completedStories_\(childId)"
    }
    
    func markStoryCompleted(_ storyId: String, forChildId childId: String) {
        var completed = getCompletedStories(forChildId: childId)
        if !completed.contains(storyId) {
            completed.append(storyId)
            UserDefaults.standard.set(completed, forKey: completedStoriesKey(forChildId: childId))
        }
    }
    
    func getCompletedStories(forChildId childId: String) -> [String] {
        return UserDefaults.standard.stringArray(forKey: completedStoriesKey(forChildId: childId)) ?? []
    }
    
    func isStoryCompleted(_ storyId: String, forChildId childId: String) -> Bool {
        return getCompletedStories(forChildId: childId).contains(storyId)
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
        
        do {
            let encoded = try JSONEncoder().encode(sessions)
            UserDefaults.standard.set(encoded, forKey: quizSessionsKey)
        } catch {
            logger.error("Error encoding quiz sessions: \(error.localizedDescription)")
        }
    }
    
    func getQuizSessions() -> [QuizSession] {
        guard let data = UserDefaults.standard.data(forKey: quizSessionsKey) else {
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([QuizSession].self, from: data)
        } catch {
            logger.error("Error decoding quiz sessions: \(error.localizedDescription)")
            // If decoding fails, clear corrupted data
            UserDefaults.standard.removeObject(forKey: quizSessionsKey)
            return []
        }
    }
    
    func getQuizSessions(for ageRange: AgeRange) -> [QuizSession] {
        return getQuizSessions().filter { $0.ageRange == ageRange }
    }
    
    func getLatestQuizSession(for ageRange: AgeRange) -> QuizSession? {
        return getQuizSessions(for: ageRange)
            .sorted { $0.startDate > $1.startDate }
            .first
    }
    
    func getQuizSessions(forChildId childId: String) -> [QuizSession] {
        // Only return quizzes that belong to this specific child
        // Exclude quizzes with nil childId (from before this feature was added)
        return getQuizSessions().filter { session in
            guard let sessionChildId = session.childId else { return false }
            return sessionChildId == childId
        }
        .sorted { $0.startDate > $1.startDate }
    }
    
    func getCompletedQuizSessions(forChildId childId: String) -> [QuizSession] {
        return getQuizSessions(forChildId: childId)
            .filter { $0.isCompleted }
    }
    
    // MARK: - Child Management
    
    func saveChild(_ child: Child) {
        var children = getChildren()
        // Remove old child with same ID if exists (for updates)
        children.removeAll { $0.id == child.id }
        // Add the new/updated child
        children.append(child)
        
        // Encode and save
        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(children)
            UserDefaults.standard.set(encoded, forKey: childrenKey)
        } catch {
            logger.error("Error saving child: \(error.localizedDescription)")
        }
    }
    
    func getChildren() -> [Child] {
        guard let data = UserDefaults.standard.data(forKey: childrenKey) else {
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            let children = try decoder.decode([Child].self, from: data)
            return children.sorted { $0.name < $1.name }
        } catch {
            logger.error("Error loading children: \(error.localizedDescription)")
            // If decoding fails, clear corrupted data
            UserDefaults.standard.removeObject(forKey: childrenKey)
            return []
        }
    }
    
    func getChild(id: String) -> Child? {
        return getChildren().first { $0.id == id }
    }
    
    func deleteChild(id: String) {
        var children = getChildren()
        children.removeAll { $0.id == id }
        
        // Encode and save
        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(children)
            UserDefaults.standard.set(encoded, forKey: childrenKey)
        } catch {
            logger.error("Error deleting child: \(error.localizedDescription)")
            return
        }
        
        // Clear selected child if it was deleted
        if getSelectedChildId() == id {
            clearSelectedChild()
        }
        
        // Clean up all child-specific data
        UserDefaults.standard.removeObject(forKey: achievementsKey(forChildId: id))
        UserDefaults.standard.removeObject(forKey: streakKey(forChildId: id))
        UserDefaults.standard.removeObject(forKey: lastActivityKey(forChildId: id))
        UserDefaults.standard.removeObject(forKey: completedStoriesKey(forChildId: id))
        UserDefaults.standard.removeObject(forKey: favoriteStoriesKey(forChildId: id))
        
        // Remove quiz sessions for this child
        var allSessions = getQuizSessions()
        allSessions.removeAll { $0.childId == id }
        do {
            let encoded = try JSONEncoder().encode(allSessions)
            UserDefaults.standard.set(encoded, forKey: quizSessionsKey)
        } catch {
            logger.error("Error encoding quiz sessions during child deletion: \(error.localizedDescription)")
        }
    }
    
    func saveSelectedChildId(_ childId: String) {
        UserDefaults.standard.set(childId, forKey: selectedChildIdKey)
    }
    
    func getSelectedChildId() -> String? {
        return UserDefaults.standard.string(forKey: selectedChildIdKey)
    }
    
    func getSelectedChild() -> Child? {
        guard let childId = getSelectedChildId() else { return nil }
        return getChild(id: childId)
    }
    
    func clearSelectedChild() {
        UserDefaults.standard.removeObject(forKey: selectedChildIdKey)
    }
    
    // MARK: - Favorite Stories Management
    
    private func favoriteStoriesKey(forChildId childId: String) -> String {
        return "favoriteStories_\(childId)"
    }
    
    func saveFavoriteStory(storyId: String, childId: String) {
        var favorites = getFavoriteStories(forChildId: childId)
        if favorites.contains(storyId) {
            // Remove from favorites (toggle off)
            favorites.removeAll { $0 == storyId }
        } else {
            // Add to favorites (toggle on)
            favorites.append(storyId)
        }
        UserDefaults.standard.set(favorites, forKey: favoriteStoriesKey(forChildId: childId))
    }
    
    func getFavoriteStories(forChildId childId: String) -> [String] {
        return UserDefaults.standard.stringArray(forKey: favoriteStoriesKey(forChildId: childId)) ?? []
    }
    
    func isStoryFavorited(storyId: String, childId: String) -> Bool {
        return getFavoriteStories(forChildId: childId).contains(storyId)
    }
    
    // MARK: - Achievement Management
    
    private func achievementsKey(forChildId childId: String) -> String {
        return "achievements_\(childId)"
    }
    
    private func streakKey(forChildId childId: String) -> String {
        return "streak_\(childId)"
    }
    
    private func lastActivityKey(forChildId childId: String) -> String {
        return "lastActivity_\(childId)"
    }
    
    func saveAchievements(forChildId childId: String, achievements: [Achievement]) {
        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(achievements)
            UserDefaults.standard.set(encoded, forKey: achievementsKey(forChildId: childId))
        } catch {
            logger.error("Error saving achievements: \(error.localizedDescription)")
        }
    }
    
    func getAchievements(forChildId childId: String) -> [Achievement] {
        guard let data = UserDefaults.standard.data(forKey: achievementsKey(forChildId: childId)) else {
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([Achievement].self, from: data)
        } catch {
            logger.error("Error decoding achievements: \(error.localizedDescription)")
            // If decoding fails, clear corrupted data
            UserDefaults.standard.removeObject(forKey: achievementsKey(forChildId: childId))
            return []
        }
    }
    
    func saveStreak(forChildId childId: String, streak: Int, lastDate: Date) {
        UserDefaults.standard.set(streak, forKey: streakKey(forChildId: childId))
        UserDefaults.standard.set(lastDate, forKey: lastActivityKey(forChildId: childId))
    }
    
    func getStreakData(forChildId childId: String) -> (streak: Int, lastDate: Date?) {
        let streak = UserDefaults.standard.integer(forKey: streakKey(forChildId: childId))
        let lastDate = UserDefaults.standard.object(forKey: lastActivityKey(forChildId: childId)) as? Date
        return (streak, lastDate)
    }
    
    // MARK: - Feelings Journal Management
    
    private func feelingsJournalKey(forChildId childId: String) -> String {
        return "feelingsJournal_\(childId)"
    }
    
    func saveJournalEntry(_ entry: FeelingsJournalEntry) {
        var entries = getJournalEntries(forChildId: entry.childId)
        // Remove old entry with same ID if exists (for updates)
        entries.removeAll { $0.id == entry.id }
        entries.append(entry)
        
        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(entries)
            UserDefaults.standard.set(encoded, forKey: feelingsJournalKey(forChildId: entry.childId))
        } catch {
            logger.error("Error saving journal entry: \(error.localizedDescription)")
        }
    }
    
    func getJournalEntries(forChildId childId: String) -> [FeelingsJournalEntry] {
        guard let data = UserDefaults.standard.data(forKey: feelingsJournalKey(forChildId: childId)) else {
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            let entries = try decoder.decode([FeelingsJournalEntry].self, from: data)
            return entries.sorted { $0.timestamp > $1.timestamp }
        } catch {
            logger.error("Error decoding journal entries: \(error.localizedDescription)")
            // If decoding fails, clear corrupted data
            UserDefaults.standard.removeObject(forKey: feelingsJournalKey(forChildId: childId))
            return []
        }
    }
    
    func hasJournalEntryToday(forChildId childId: String) -> Bool {
        let entries = getJournalEntries(forChildId: childId)
        return entries.contains { $0.isToday }
    }
    
    func getTodaysJournalEntry(forChildId childId: String) -> FeelingsJournalEntry? {
        let entries = getJournalEntries(forChildId: childId)
        return entries.first { $0.isToday }
    }
    
    func deleteJournalEntry(_ entry: FeelingsJournalEntry) {
        var entries = getJournalEntries(forChildId: entry.childId)
        entries.removeAll { $0.id == entry.id }
        
        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(entries)
            UserDefaults.standard.set(encoded, forKey: feelingsJournalKey(forChildId: entry.childId))
        } catch {
            logger.error("Error deleting journal entry: \(error.localizedDescription)")
        }
    }
}

