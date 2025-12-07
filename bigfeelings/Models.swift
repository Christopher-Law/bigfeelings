//
//  Models.swift
//  bigfeelings
//
//  Created by Christopher Law on 2025-12-07.
//

import Foundation

enum AgeRange: String, Codable, CaseIterable {
    case fourToSix = "4-6"
    case sevenToNine = "7-9"
    case tenToTwelve = "10-12"
    
    var displayName: String {
        switch self {
        case .fourToSix: return "Ages 4-6"
        case .sevenToNine: return "Ages 7-9"
        case .tenToTwelve: return "Ages 10-12"
        }
    }
    
    var colorName: String {
        switch self {
        case .fourToSix: return "lavender"
        case .sevenToNine: return "mint"
        case .tenToTwelve: return "peach"
        }
    }
}

enum ChoiceID: String, Codable {
    case a, b, c, d
}

enum ChoiceType: String, Codable {
    case good
    case okay
    case bad
    case unrelated
    
    var colorName: String {
        switch self {
        case .good: return "soft-green"
        case .okay: return "warm-yellow"
        case .bad: return "soft-orange"
        case .unrelated: return "soft-purple"
        }
    }
    
    var emoji: String {
        switch self {
        case .good: return "🌟"
        case .okay: return "🤔"
        case .bad: return "💭"
        case .unrelated: return "💭"
        }
    }
    
    var title: String {
        switch self {
        case .good: return "Great Choice!"
        case .okay: return "Almost There!"
        case .bad: return "Let's Try a Different Way"
        case .unrelated: return "Let's Focus on This"
        }
    }
}

struct Choice: Codable, Identifiable {
    let id: ChoiceID
    let text: String
    let type: ChoiceType
    let explanation: String
}

struct Story: Codable, Identifiable {
    let id: String
    let ageRange: AgeRange
    let animal: String
    let animalEmoji: String
    let title: String
    let feeling: String
    let story: String
    let imagePrompt: String
    let choices: [Choice]
    let endingMessage: String
}

// MARK: - Quiz Models

struct QuizAnswer: Codable {
    let storyId: String
    let storyTitle: String
    let feeling: String
    let selectedChoiceId: ChoiceID
    let selectedChoiceType: ChoiceType
    let timestamp: Date
}

struct QuizSession: Codable, Identifiable {
    let id: String
    let ageRange: AgeRange
    let startDate: Date
    let endDate: Date?
    let answers: [QuizAnswer]
    
    var isCompleted: Bool {
        endDate != nil
    }
    
    var totalStories: Int {
        answers.count
    }
    
    var score: QuizScore {
        QuizScore(from: answers)
    }
}

struct QuizScore {
    let total: Int
    let good: Int
    let okay: Int
    let bad: Int
    let unrelated: Int
    
    var goodPercentage: Double {
        guard total > 0 else { return 0 }
        return Double(good) / Double(total) * 100
    }
    
    var overallGrade: String {
        let percentage = goodPercentage
        switch percentage {
        case 80...100: return "Excellent"
        case 60..<80: return "Good"
        case 40..<60: return "Fair"
        default: return "Keep Learning"
        }
    }
    
    init(from answers: [QuizAnswer]) {
        total = answers.count
        good = answers.filter { $0.selectedChoiceType == .good }.count
        okay = answers.filter { $0.selectedChoiceType == .okay }.count
        bad = answers.filter { $0.selectedChoiceType == .bad }.count
        unrelated = answers.filter { $0.selectedChoiceType == .unrelated }.count
    }
}

