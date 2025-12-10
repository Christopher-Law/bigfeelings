//
//  Achievement.swift
//  bigfeelings
//
//  Created by Christopher Law on 2025-12-07.
//

import Foundation

struct Achievement: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let category: AchievementCategory
    let requirement: Int
    var currentProgress: Int
    var isUnlocked: Bool
    var unlockedDate: Date?
    
    var progressPercentage: Double {
        guard requirement > 0 else { return 0 }
        return min(100, Double(currentProgress) / Double(requirement) * 100)
    }
}

enum AchievementCategory: String, Codable, CaseIterable {
    case stories
    case quizzes
    case streaks
    case feelings
    case milestones
    
    var displayName: String {
        switch self {
        case .stories: return "Stories"
        case .quizzes: return "Quizzes"
        case .streaks: return "Streaks"
        case .feelings: return "Feelings"
        case .milestones: return "Milestones"
        }
    }
}

extension Achievement {
    static func getAllAchievements() -> [Achievement] {
        return [
            // Stories (6 achievements)
            Achievement(
                id: "first_story",
                title: "First Story",
                description: "Read your first story",
                icon: "book.fill",
                category: .stories,
                requirement: 1,
                currentProgress: 0,
                isUnlocked: false,
                unlockedDate: nil
            ),
            Achievement(
                id: "bookworm",
                title: "Bookworm",
                description: "Read 5 stories",
                icon: "books.vertical.fill",
                category: .stories,
                requirement: 5,
                currentProgress: 0,
                isUnlocked: false,
                unlockedDate: nil
            ),
            Achievement(
                id: "story_explorer",
                title: "Story Explorer",
                description: "Read 10 stories",
                icon: "map.fill",
                category: .stories,
                requirement: 10,
                currentProgress: 0,
                isUnlocked: false,
                unlockedDate: nil
            ),
            Achievement(
                id: "story_master",
                title: "Story Master",
                description: "Read 25 stories",
                icon: "crown.fill",
                category: .stories,
                requirement: 25,
                currentProgress: 0,
                isUnlocked: false,
                unlockedDate: nil
            ),
            Achievement(
                id: "favorite_fan",
                title: "Favorite Fan",
                description: "Favorite 3 stories",
                icon: "heart.fill",
                category: .stories,
                requirement: 3,
                currentProgress: 0,
                isUnlocked: false,
                unlockedDate: nil
            ),
            Achievement(
                id: "super_fan",
                title: "Super Fan",
                description: "Favorite 10 stories",
                icon: "heart.circle.fill",
                category: .stories,
                requirement: 10,
                currentProgress: 0,
                isUnlocked: false,
                unlockedDate: nil
            ),
            
            // Quizzes (6 achievements)
            Achievement(
                id: "first_quiz",
                title: "First Quiz",
                description: "Complete your first quiz",
                icon: "checkmark.circle.fill",
                category: .quizzes,
                requirement: 1,
                currentProgress: 0,
                isUnlocked: false,
                unlockedDate: nil
            ),
            Achievement(
                id: "quiz_rookie",
                title: "Quiz Rookie",
                description: "Complete 5 quizzes",
                icon: "graduationcap.fill",
                category: .quizzes,
                requirement: 5,
                currentProgress: 0,
                isUnlocked: false,
                unlockedDate: nil
            ),
            Achievement(
                id: "quiz_pro",
                title: "Quiz Pro",
                description: "Complete 10 quizzes",
                icon: "star.fill",
                category: .quizzes,
                requirement: 10,
                currentProgress: 0,
                isUnlocked: false,
                unlockedDate: nil
            ),
            Achievement(
                id: "quiz_master",
                title: "Quiz Master",
                description: "Complete 25 quizzes",
                icon: "trophy.fill",
                category: .quizzes,
                requirement: 25,
                currentProgress: 0,
                isUnlocked: false,
                unlockedDate: nil
            ),
            Achievement(
                id: "perfect_score",
                title: "Perfect Score",
                description: "Get 100% on a quiz",
                icon: "checkmark.seal.fill",
                category: .quizzes,
                requirement: 1,
                currentProgress: 0,
                isUnlocked: false,
                unlockedDate: nil
            ),
            Achievement(
                id: "high_achiever",
                title: "High Achiever",
                description: "Get 80% or higher on 5 quizzes",
                icon: "chart.line.uptrend.xyaxis",
                category: .quizzes,
                requirement: 5,
                currentProgress: 0,
                isUnlocked: false,
                unlockedDate: nil
            ),
            
            // Streaks (4 achievements)
            Achievement(
                id: "getting_started",
                title: "Getting Started",
                description: "Maintain a 3-day streak",
                icon: "flame.fill",
                category: .streaks,
                requirement: 3,
                currentProgress: 0,
                isUnlocked: false,
                unlockedDate: nil
            ),
            Achievement(
                id: "week_warrior",
                title: "Week Warrior",
                description: "Maintain a 7-day streak",
                icon: "calendar",
                category: .streaks,
                requirement: 7,
                currentProgress: 0,
                isUnlocked: false,
                unlockedDate: nil
            ),
            Achievement(
                id: "two_week_champion",
                title: "Two Week Champion",
                description: "Maintain a 14-day streak",
                icon: "calendar.badge.clock",
                category: .streaks,
                requirement: 14,
                currentProgress: 0,
                isUnlocked: false,
                unlockedDate: nil
            ),
            Achievement(
                id: "month_of_growth",
                title: "Month of Growth",
                description: "Maintain a 30-day streak",
                icon: "calendar.badge.exclamationmark",
                category: .streaks,
                requirement: 30,
                currentProgress: 0,
                isUnlocked: false,
                unlockedDate: nil
            ),
            
            // Feelings (4 achievements)
            Achievement(
                id: "brave_heart",
                title: "Brave Heart",
                description: "Complete 3 stories about fear or being scared",
                icon: "shield.fill",
                category: .feelings,
                requirement: 3,
                currentProgress: 0,
                isUnlocked: false,
                unlockedDate: nil
            ),
            Achievement(
                id: "calm_mind",
                title: "Calm Mind",
                description: "Complete 3 stories about anger or frustration",
                icon: "leaf.fill",
                category: .feelings,
                requirement: 3,
                currentProgress: 0,
                isUnlocked: false,
                unlockedDate: nil
            ),
            Achievement(
                id: "social_star",
                title: "Social Star",
                description: "Complete 3 stories about loneliness or friendship",
                icon: "person.2.fill",
                category: .feelings,
                requirement: 3,
                currentProgress: 0,
                isUnlocked: false,
                unlockedDate: nil
            ),
            Achievement(
                id: "worry_warrior",
                title: "Worry Warrior",
                description: "Complete 3 stories about anxiety or worry",
                icon: "brain.head.profile",
                category: .feelings,
                requirement: 3,
                currentProgress: 0,
                isUnlocked: false,
                unlockedDate: nil
            ),
            
            // Milestones (5 achievements)
            Achievement(
                id: "emotional_explorer",
                title: "Emotional Explorer",
                description: "Explore stories with 5 different feelings",
                icon: "map.circle.fill",
                category: .milestones,
                requirement: 5,
                currentProgress: 0,
                isUnlocked: false,
                unlockedDate: nil
            ),
            Achievement(
                id: "feeling_expert",
                title: "Feeling Expert",
                description: "Explore stories with 10 different feelings",
                icon: "brain",
                category: .milestones,
                requirement: 10,
                currentProgress: 0,
                isUnlocked: false,
                unlockedDate: nil
            ),
            Achievement(
                id: "all_rounder",
                title: "All-Rounder",
                description: "Complete at least 1 story and 1 quiz",
                icon: "star.circle.fill",
                category: .milestones,
                requirement: 1,
                currentProgress: 0,
                isUnlocked: false,
                unlockedDate: nil
            ),
            Achievement(
                id: "rising_star",
                title: "Rising Star",
                description: "Maintain 50% or higher overall quiz average",
                icon: "star.fill",
                category: .milestones,
                requirement: 1,
                currentProgress: 0,
                isUnlocked: false,
                unlockedDate: nil
            ),
            Achievement(
                id: "consistent_learner",
                title: "Consistent Learner",
                description: "Get 60% or higher on 10 quizzes",
                icon: "chart.bar.fill",
                category: .milestones,
                requirement: 10,
                currentProgress: 0,
                isUnlocked: false,
                unlockedDate: nil
            )
        ]
    }
}
