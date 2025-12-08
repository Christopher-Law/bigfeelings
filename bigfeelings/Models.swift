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
    let childId: String?
    
    var isCompleted: Bool {
        endDate != nil
    }
    
    var totalStories: Int {
        answers.count
    }
    
    var score: QuizScore {
        QuizScore(from: answers)
    }
    
    init(id: String, ageRange: AgeRange, startDate: Date, endDate: Date?, answers: [QuizAnswer], childId: String? = nil) {
        self.id = id
        self.ageRange = ageRange
        self.startDate = startDate
        self.endDate = endDate
        self.answers = answers
        self.childId = childId
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

// MARK: - Child/Client Models

struct Child: Codable, Identifiable {
    let id: String
    var name: String
    var age: Int?
    var notes: String?
    let createdAt: Date
    var updatedAt: Date
    
    init(id: String = UUID().uuidString, name: String, age: Int? = nil, notes: String? = nil, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.age = age
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // Calculate age range from numeric age
    var ageRange: AgeRange? {
        guard let age = age else { return nil }
        switch age {
        case 4...6: return .fourToSix
        case 7...9: return .sevenToNine
        case 10...12: return .tenToTwelve
        default:
            // Default to middle range if age is outside expected range
            return .sevenToNine
        }
    }
}

// MARK: - Feelings Journal Models

struct FeelingsJournalEntry: Codable, Identifiable {
    let id: String
    let childId: String
    let feelingEmoji: String
    let feelingName: String
    let notes: String?
    let timestamp: Date
    
    init(id: String = UUID().uuidString, childId: String, feelingEmoji: String, feelingName: String, notes: String? = nil, timestamp: Date = Date()) {
        self.id = id
        self.childId = childId
        self.feelingEmoji = feelingEmoji
        self.feelingName = feelingName
        self.notes = notes
        self.timestamp = timestamp
    }
    
    // Check if entry is from today
    var isToday: Bool {
        Calendar.current.isDateInToday(timestamp)
    }
    
    // Get date string for display
    var dateString: String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(timestamp) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(timestamp) {
            return "Yesterday"
        } else {
            formatter.dateStyle = .medium
            return formatter.string(from: timestamp)
        }
    }
}

// Common feelings with emojis for check-in
struct FeelingOption: Identifiable {
    let id: String
    let emoji: String
    let name: String
    
    static let commonFeelings: [FeelingOption] = [
        FeelingOption(id: "happy", emoji: "😊", name: "Happy"),
        FeelingOption(id: "sad", emoji: "😢", name: "Sad"),
        FeelingOption(id: "angry", emoji: "😠", name: "Angry"),
        FeelingOption(id: "excited", emoji: "🤩", name: "Excited"),
        FeelingOption(id: "worried", emoji: "😟", name: "Worried"),
        FeelingOption(id: "calm", emoji: "😌", name: "Calm"),
        FeelingOption(id: "proud", emoji: "😎", name: "Proud"),
        FeelingOption(id: "scared", emoji: "😨", name: "Scared"),
        FeelingOption(id: "confused", emoji: "😕", name: "Confused"),
        FeelingOption(id: "grateful", emoji: "🙏", name: "Grateful"),
        FeelingOption(id: "lonely", emoji: "😔", name: "Lonely"),
        FeelingOption(id: "loved", emoji: "🥰", name: "Loved"),
        FeelingOption(id: "frustrated", emoji: "😤", name: "Frustrated"),
        FeelingOption(id: "peaceful", emoji: "☺️", name: "Peaceful"),
        FeelingOption(id: "silly", emoji: "😜", name: "Silly"),
        FeelingOption(id: "tired", emoji: "😴", name: "Tired")
    ]
}

