//
//  QuizSummaryGenerator.swift
//  bigfeelings
//
//  Created by Christopher Law on 2025-12-07.
//

import Foundation

class QuizSummaryGenerator {
    static let shared = QuizSummaryGenerator()
    
    private init() {}
    
    func generateSummary(for session: QuizSession) -> String {
        let score = session.score
        let answers = session.answers
        
        // Overall performance
        let overallSection = generateOverallSection(score: score)
        
        // Strengths
        let strengthsSection = generateStrengthsSection(answers: answers, score: score)
        
        // Areas for growth
        let growthSection = generateGrowthSection(answers: answers, score: score)
        
        // Feeling-specific insights
        let feelingInsights = generateFeelingInsights(answers: answers)
        
        // Combine all sections
        var summary = overallSection
        summary += "\n\n" + strengthsSection
        
        if !growthSection.isEmpty {
            summary += "\n\n" + growthSection
        }
        
        if !feelingInsights.isEmpty {
            summary += "\n\n" + feelingInsights
        }
        
        // Add encouraging closing
        summary += "\n\n" + generateEncouragingClosing(score: score)
        
        return summary
    }
    
    private func generateOverallSection(score: QuizScore) -> String {
        let percentage = Int(score.goodPercentage)
        let grade = score.overallGrade
        
        var section = "📊 **Overall Performance**\n\n"
        section += "Completed \(score.total) scenarios with \(score.good) great choices (\(percentage)%). "
        
        switch grade {
        case "Excellent":
            section += "Outstanding work! The child consistently demonstrates strong emotional decision-making skills. Continue reinforcing these positive choices."
        case "Good":
            section += "Good progress! The child shows understanding of healthy coping strategies. Continue practicing these skills together to build confidence."
        case "Fair":
            section += "The child is learning to navigate emotional situations. Consistent practice and gentle guidance will help them continue to improve."
        default:
            section += "The child is beginning their journey in emotional learning. Patient, consistent practice and supportive guidance are essential to help build these important skills."
        }
        
        return section
    }
    
    private func generateStrengthsSection(answers: [QuizAnswer], score: QuizScore) -> String {
        var section = "🌟 **Strengths**\n\n"
        
        if score.goodPercentage >= 70 {
            section += "• Consistently makes healthy choices in emotional situations\n"
        }
        
        if score.good > 0 {
            let goodStories = answers.filter { $0.selectedChoiceType == .good }
            let uniqueFeelings = Set(goodStories.map { $0.feeling })
            if uniqueFeelings.count >= 3 {
                section += "• Shows understanding across multiple emotional contexts\n"
            }
        }
        
        if score.okay > 0 && score.bad == 0 && score.unrelated == 0 {
            section += "• Demonstrates thoughtful consideration of choices\n"
        }
        
        // Find most common feeling where good choices were made
        let goodByFeeling = Dictionary(grouping: answers.filter { $0.selectedChoiceType == .good }) { $0.feeling }
        if let topFeeling = goodByFeeling.max(by: { $0.value.count < $1.value.count }) {
            if topFeeling.value.count >= 2 {
                section += "• Particularly strong in handling \"\(topFeeling.key)\" situations\n"
            }
        }
        
        if section == "🌟 **Strengths**\n\n" {
            section += "• Completed all scenarios, showing engagement and willingness to learn\n"
        }
        
        return section
    }
    
    private func generateGrowthSection(answers: [QuizAnswer], score: QuizScore) -> String {
        var section = "💡 **Areas for Growth**\n\n"
        var hasContent = false
        
        if score.bad > 0 {
            let badStories = answers.filter { $0.selectedChoiceType == .bad }
            let badFeelings = Set(badStories.map { $0.feeling })
            if !badFeelings.isEmpty {
                section += "• Opportunities to explore together: \(badFeelings.joined(separator: ", "))\n"
                hasContent = true
            }
        }
        
        if score.unrelated > 0 {
            section += "• Sometimes needs help focusing on what's most important in each situation\n"
            hasContent = true
        }
        
        if score.okay > score.good {
            section += "• Shows good thinking by considering options, and with practice can learn to identify the most helpful choices\n"
            hasContent = true
        }
        
        if score.goodPercentage < 50 {
            let challengingFeelings = Set(answers.filter { $0.selectedChoiceType != .good }.map { $0.feeling })
            if !challengingFeelings.isEmpty {
                section += "• Needs consistent practice and support with: \(Array(challengingFeelings).prefix(3).joined(separator: ", "))\n"
                hasContent = true
            }
        }
        
        if !hasContent {
            return ""
        }
        
        return section
    }
    
    private func generateFeelingInsights(answers: [QuizAnswer]) -> String {
        let feelingGroups = Dictionary(grouping: answers) { $0.feeling }
        var insights: [String] = []
        
        for (feeling, feelingAnswers) in feelingGroups {
            let goodCount = feelingAnswers.filter { $0.selectedChoiceType == .good }.count
            let totalCount = feelingAnswers.count
            
            if totalCount >= 2 {
                let percentage = Double(goodCount) / Double(totalCount) * 100
                
                if percentage >= 75 {
                    insights.append("• Strong performance with \"\(feeling)\" scenarios (\(goodCount)/\(totalCount) great choices)")
                } else if percentage < 50 {
                    insights.append("• \"\(feeling)\" scenarios offer great learning opportunities (\(goodCount)/\(totalCount) great choices)")
                }
            }
        }
        
        if insights.isEmpty {
            return ""
        }
        
        return "📈 **Emotional Context Insights**\n\n" + insights.joined(separator: "\n")
    }
    
    private func generateEncouragingClosing(score: QuizScore) -> String {
        let percentage = Int(score.goodPercentage)
        
        switch percentage {
        case 80...100:
            return "✨ **Summary**: This child demonstrates excellent emotional intelligence and decision-making. Continue providing consistent opportunities to practice these skills in real-life situations to maintain this strong foundation."
        case 60..<80:
            return "✨ **Summary**: This child shows good understanding of emotional regulation. With continued, consistent practice and supportive guidance, they will further develop these important life skills."
        case 40..<60:
            return "✨ **Summary**: This child is learning to navigate emotions and make healthy choices. Regular, structured practice with these scenarios and real-world application is needed to support their continued growth."
        default:
            return "✨ **Summary**: This child is beginning to learn about emotions and healthy coping strategies. Patient but consistent guidance, repeated practice, and celebrating small wins are essential to help build their confidence and skills."
        }
    }
}
