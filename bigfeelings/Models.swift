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
        case .okay: return "Let's Think About This"
        case .bad: return "Let's Think"
        case .unrelated: return "Let's Think"
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

