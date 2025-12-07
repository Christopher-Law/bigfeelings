//
//  AchievementManager.swift
//  bigfeelings
//
//  Created by Christopher Law on 2025-12-07.
//

import Foundation

class AchievementManager {
    static let shared = AchievementManager()
    
    private init() {}
    
    func getAchievements(forChildId childId: String) -> [Achievement] {
        var achievements = Achievement.getAllAchievements()
        
        // Load saved progress
        let savedAchievements = UserDefaultsManager.shared.getAchievements(forChildId: childId)
        let savedDict = Dictionary(uniqueKeysWithValues: savedAchievements.map { ($0.id, $0) })
        
        // Calculate current progress for each achievement
        for i in 0..<achievements.count {
            var achievement = achievements[i]
            
            // Restore saved state if exists
            if let saved = savedDict[achievement.id] {
                achievement.isUnlocked = saved.isUnlocked
                achievement.unlockedDate = saved.unlockedDate
            }
            
            // Calculate current progress based on achievement type
            achievement.currentProgress = calculateProgress(for: achievement, childId: childId)
            
            // Auto-unlock if requirement met
            if !achievement.isUnlocked && achievement.currentProgress >= achievement.requirement {
                achievement.isUnlocked = true
                achievement.unlockedDate = Date()
            }
            
            achievements[i] = achievement
        }
        
        // Save updated achievements
        UserDefaultsManager.shared.saveAchievements(forChildId: childId, achievements: achievements)
        
        return achievements
    }
    
    func checkAchievements(forChildId childId: String) -> [Achievement] {
        var achievements = getAchievements(forChildId: childId)
        var newlyUnlocked: [Achievement] = []
        
        for i in 0..<achievements.count {
            var achievement = achievements[i]
            
            // Calculate current progress
            achievement.currentProgress = calculateProgress(for: achievement, childId: childId)
            
            // Check if should be unlocked
            if !achievement.isUnlocked && achievement.currentProgress >= achievement.requirement {
                achievement.isUnlocked = true
                achievement.unlockedDate = Date()
                newlyUnlocked.append(achievement)
            }
            
            achievements[i] = achievement
        }
        
        // Save updated achievements
        UserDefaultsManager.shared.saveAchievements(forChildId: childId, achievements: achievements)
        
        return newlyUnlocked
    }
    
    func recordActivity(forChildId childId: String) {
        let calendar = Calendar.current
        let now = Date()
        let (currentStreak, lastDate) = UserDefaultsManager.shared.getStreakData(forChildId: childId)
        
        guard let lastActivityDate = lastDate else {
            // First activity - start streak
            UserDefaultsManager.shared.saveStreak(forChildId: childId, streak: 1, lastDate: now)
            return
        }
        
        // Check if last activity was today
        if calendar.isDateInToday(lastActivityDate) {
            // Already recorded today, don't increment
            return
        }
        
        // Check if last activity was yesterday (continuing streak)
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now),
           calendar.isDate(lastActivityDate, inSameDayAs: yesterday) {
            // Continue streak
            UserDefaultsManager.shared.saveStreak(forChildId: childId, streak: currentStreak + 1, lastDate: now)
        } else {
            // Streak broken - start new streak
            UserDefaultsManager.shared.saveStreak(forChildId: childId, streak: 1, lastDate: now)
        }
    }
    
    func getCurrentStreak(forChildId childId: String) -> Int {
        let (streak, lastDate) = UserDefaultsManager.shared.getStreakData(forChildId: childId)
        
        guard let lastActivityDate = lastDate else {
            return 0
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        // If last activity was today, return current streak
        if calendar.isDateInToday(lastActivityDate) {
            return streak
        }
        
        // If last activity was yesterday, streak is still valid
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now),
           calendar.isDate(lastActivityDate, inSameDayAs: yesterday) {
            return streak
        }
        
        // Streak broken
        return 0
    }
    
    func getLastActivityDate(forChildId childId: String) -> Date? {
        let (_, lastDate) = UserDefaultsManager.shared.getStreakData(forChildId: childId)
        return lastDate
    }
    
    // MARK: - Private Helpers
    
    private func calculateProgress(for achievement: Achievement, childId: String) -> Int {
        switch achievement.id {
        // Story count achievements
        case "first_story", "bookworm", "story_explorer", "story_master":
            // Get stories completed by this child
            let completedStories = UserDefaultsManager.shared.getCompletedStories(forChildId: childId)
            // Also include stories from quiz answers
            let quizSessions = UserDefaultsManager.shared.getCompletedQuizSessions(forChildId: childId)
            let quizStoryIds = Set(quizSessions.flatMap { $0.answers.map { $0.storyId } })
            let allCompleted = Set(completedStories).union(quizStoryIds)
            return allCompleted.count
            
        // Favorite count achievements
        case "favorite_fan", "super_fan":
            let favorites = UserDefaultsManager.shared.getFavoriteStories(forChildId: childId)
            return favorites.count
            
        // Quiz count achievements
        case "first_quiz", "quiz_rookie", "quiz_pro", "quiz_master":
            let quizzes = UserDefaultsManager.shared.getCompletedQuizSessions(forChildId: childId)
            return quizzes.count
            
        // Perfect score achievement
        case "perfect_score":
            let quizzes = UserDefaultsManager.shared.getCompletedQuizSessions(forChildId: childId)
            let perfectQuizzes = quizzes.filter { $0.score.goodPercentage >= 100 }
            return perfectQuizzes.count
            
        // High achiever (80%+ on 5 quizzes)
        case "high_achiever":
            let quizzes = UserDefaultsManager.shared.getCompletedQuizSessions(forChildId: childId)
            let highScoreQuizzes = quizzes.filter { $0.score.goodPercentage >= 80 }
            return min(highScoreQuizzes.count, achievement.requirement)
            
        // Streak achievements
        case "getting_started", "week_warrior", "two_week_champion", "month_of_growth":
            return getCurrentStreak(forChildId: childId)
            
        // Feeling-specific achievements
        case "brave_heart":
            return countStoriesByFeeling(childId: childId, feelings: ["scared", "fear"])
        case "calm_mind":
            return countStoriesByFeeling(childId: childId, feelings: ["angry", "frustrated"])
        case "social_star":
            return countStoriesByFeeling(childId: childId, feelings: ["lonely", "hurt"])
        case "worry_warrior":
            return countStoriesByFeeling(childId: childId, feelings: ["anxious", "worried", "nervous"])
            
        // Unique feelings explored
        case "emotional_explorer", "feeling_expert":
            let uniqueFeelings = getUniqueFeelingsExplored(childId: childId)
            return uniqueFeelings.count
            
        // All-rounder (1 story + 1 quiz)
        case "all_rounder":
            let completedStories = UserDefaultsManager.shared.getCompletedStories(forChildId: childId)
            let quizSessions = UserDefaultsManager.shared.getCompletedQuizSessions(forChildId: childId)
            let quizStoryIds = Set(quizSessions.flatMap { $0.answers.map { $0.storyId } })
            let allCompleted = Set(completedStories).union(quizStoryIds)
            let storyCount = allCompleted.count
            let quizCount = quizSessions.count
            return (storyCount > 0 && quizCount > 0) ? 1 : 0
            
        // Rising star (50%+ overall average)
        case "rising_star":
            let quizzes = UserDefaultsManager.shared.getCompletedQuizSessions(forChildId: childId)
            guard !quizzes.isEmpty else { return 0 }
            let average = quizzes.reduce(0.0) { $0 + $1.score.goodPercentage } / Double(quizzes.count)
            return average >= 50 ? 1 : 0
            
        // Consistent learner (60%+ on 10 quizzes)
        case "consistent_learner":
            let quizzes = UserDefaultsManager.shared.getCompletedQuizSessions(forChildId: childId)
            let consistentQuizzes = quizzes.filter { $0.score.goodPercentage >= 60 }
            return min(consistentQuizzes.count, achievement.requirement)
            
        default:
            return 0
        }
    }
    
    private func countStoriesByFeeling(childId: String, feelings: [String]) -> Int {
        // Get all stories from all age ranges
        let allStories = StoryLoader.shared.getAllStories()
        let completedStoryIds = UserDefaultsManager.shared.getCompletedStories(forChildId: childId)
        
        // Also include stories from quiz answers
        let quizSessions = UserDefaultsManager.shared.getCompletedQuizSessions(forChildId: childId)
        let quizStoryIds = Set(quizSessions.flatMap { $0.answers.map { $0.storyId } })
        let allCompletedIds = Set(completedStoryIds).union(quizStoryIds)
        
        // Filter completed stories that match the feelings
        let matchingStories = allStories.filter { story in
            allCompletedIds.contains(story.id) &&
            feelings.contains { feeling in
                story.feeling.lowercased().contains(feeling.lowercased())
            }
        }
        
        return matchingStories.count
    }
    
    private func getUniqueFeelingsExplored(childId: String) -> Set<String> {
        let allStories = StoryLoader.shared.getAllStories()
        let completedStoryIds = UserDefaultsManager.shared.getCompletedStories(forChildId: childId)
        
        // Also include stories from quiz answers
        let quizSessions = UserDefaultsManager.shared.getCompletedQuizSessions(forChildId: childId)
        let quizStoryIds = Set(quizSessions.flatMap { $0.answers.map { $0.storyId } })
        let allCompletedIds = Set(completedStoryIds).union(quizStoryIds)
        
        let completedStories = allStories.filter { allCompletedIds.contains($0.id) }
        let uniqueFeelings = Set(completedStories.map { $0.feeling.lowercased() })
        
        return uniqueFeelings
    }
}
