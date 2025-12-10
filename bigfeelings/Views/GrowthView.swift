//
//  GrowthView.swift
//  bigfeelings
//
//  Created by Christopher Law on 2025-12-07.
//

import SwiftUI

struct GrowthView: View {
    let child: Child
    @State private var quizSessions: [QuizSession] = []
    
    private var completedSessions: [QuizSession] {
        quizSessions.filter { $0.isCompleted }
    }
    
    var body: some View {
        ZStack {
            // Background - matching Welcome screen style
            LinearGradient(
                colors: [
                    Color.lavender.opacity(0.4),
                    Color.mint.opacity(0.4),
                    Color.sky.opacity(0.3),
                    Color.cream.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if completedSessions.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 64))
                        .foregroundColor(.secondary)
                    
                    Text("Your Journey Starts Here")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Complete story explorations to see \(child.name)'s amazing progress!")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        // Progress overview card with summary
                        if completedSessions.count > 1 {
                            ProgressOverviewCard(sessions: completedSessions, childName: child.name)
                                .padding(.horizontal, 20)
                        } else if completedSessions.count == 1 {
                            // Show summary card even with just one session
                            ChildProgressSummaryCard(sessions: completedSessions, childName: child.name)
                                .padding(.horizontal, 20)
                        }
                        
                        // Quiz sessions list
                        VStack(spacing: 16) {
                            ForEach(completedSessions) { session in
                                QuizSessionCard(session: session)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .navigationTitle("Growth")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            loadQuizSessions()
        }
    }
    
    private func loadQuizSessions() {
        // Only load quizzes for this specific child
        // getQuizSessions(forChildId:) ensures only quizzes belonging to this child are returned
        quizSessions = UserDefaultsManager.shared.getQuizSessions(forChildId: child.id)
    }
}

struct ProgressOverviewCard: View {
    let sessions: [QuizSession]
    let childName: String
    
    private var averageScore: Double {
        guard !sessions.isEmpty else { return 0 }
        let total = sessions.reduce(0.0) { $0 + $1.score.goodPercentage }
        return total / Double(sessions.count)
    }
    
    private var summary: String {
        let percentage = Int(averageScore)
        
        switch percentage {
        case 80...100:
            return "\(childName) demonstrates excellent emotional intelligence and decision-making. Continue providing consistent opportunities to practice these skills in real-life situations to maintain this strong foundation."
        case 60..<80:
            return "\(childName) shows good understanding of emotional regulation. With continued, consistent practice and supportive guidance, they will further develop these important life skills."
        case 40..<60:
            return "\(childName) is learning to navigate emotions and make healthy choices. Regular, structured practice with these scenarios and real-world application is needed to support their continued growth."
        default:
            return "\(childName) is beginning to learn about emotions and healthy coping strategies. Patient but consistent guidance, repeated practice, and celebrating small wins are essential to help build their confidence and skills."
        }
    }
    
    private var strugglingFeelings: [String] {
        // Get all answers from all sessions
        let allAnswers = sessions.flatMap { $0.answers }
        
        // Group answers by feeling
        let feelingGroups = Dictionary(grouping: allAnswers) { $0.feeling }
        
        // Calculate success rate for each feeling (percentage of "good" choices)
        var feelingScores: [(feeling: String, successRate: Double, count: Int)] = []
        
        for (feeling, answers) in feelingGroups {
            let goodCount = answers.filter { $0.selectedChoiceType == .good }.count
            let totalCount = answers.count
            let successRate = totalCount > 0 ? Double(goodCount) / Double(totalCount) : 0.0
            
            // Only include feelings with at least 2 attempts for meaningful data
            if totalCount >= 2 {
                feelingScores.append((feeling: feeling, successRate: successRate, count: totalCount))
            }
        }
        
        // Sort by success rate (lowest first) and return top 3-5 struggling feelings
        let struggling = feelingScores
            .sorted { $0.successRate < $1.successRate }
            .prefix(5)
            .filter { $0.successRate < 0.75 } // Only include feelings with < 75% success rate
            .map { $0.feeling }
        
        return Array(struggling)
    }
    
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Progress Overview")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Story Explorations")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                    Text("\(sessions.count)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Average Score")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                    Text("\(Int(averageScore))%")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }
            }
            
            // Summary section
            Divider()
                .padding(.vertical, 8)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("How \(childName) is Doing")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(summary)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // Growth area - struggling feelings
            if !strugglingFeelings.isEmpty {
                Divider()
                    .padding(.vertical, 8)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Areas for Growth")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Feelings to practice together: \(strugglingFeelings.joined(separator: ", "))")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.9))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
}

struct ChildProgressSummaryCard: View {
    let sessions: [QuizSession]
    let childName: String
    
    private var averageScore: Double {
        guard !sessions.isEmpty else { return 0 }
        let total = sessions.reduce(0.0) { $0 + $1.score.goodPercentage }
        return total / Double(sessions.count)
    }
    
    private var summary: String {
        let percentage = Int(averageScore)
        
        switch percentage {
        case 80...100:
            return "\(childName) demonstrates excellent emotional intelligence and decision-making. Continue providing consistent opportunities to practice these skills in real-life situations to maintain this strong foundation."
        case 60..<80:
            return "\(childName) shows good understanding of emotional regulation. With continued, consistent practice and supportive guidance, they will further develop these important life skills."
        case 40..<60:
            return "\(childName) is learning to navigate emotions and make healthy choices. Regular, structured practice with these scenarios and real-world application is needed to support their continued growth."
        default:
            return "\(childName) is beginning to learn about emotions and healthy coping strategies. Patient but consistent guidance, repeated practice, and celebrating small wins are essential to help build their confidence and skills."
        }
    }
    
    private var strugglingFeelings: [String] {
        // Get all answers from all sessions
        let allAnswers = sessions.flatMap { $0.answers }
        
        // Group answers by feeling
        let feelingGroups = Dictionary(grouping: allAnswers) { $0.feeling }
        
        // Calculate success rate for each feeling (percentage of "good" choices)
        var feelingScores: [(feeling: String, successRate: Double, count: Int)] = []
        
        for (feeling, answers) in feelingGroups {
            let goodCount = answers.filter { $0.selectedChoiceType == .good }.count
            let totalCount = answers.count
            let successRate = totalCount > 0 ? Double(goodCount) / Double(totalCount) : 0.0
            
            // Only include feelings with at least 2 attempts for meaningful data
            if totalCount >= 2 {
                feelingScores.append((feeling: feeling, successRate: successRate, count: totalCount))
            }
        }
        
        // Sort by success rate (lowest first) and return top 3-5 struggling feelings
        let struggling = feelingScores
            .sorted { $0.successRate < $1.successRate }
            .prefix(5)
            .filter { $0.successRate < 0.75 } // Only include feelings with < 75% success rate
            .map { $0.feeling }
        
        return Array(struggling)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How \(childName) is Doing")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(summary)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            // Growth area - struggling feelings
            if !strugglingFeelings.isEmpty {
                Divider()
                    .padding(.vertical, 8)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Areas for Growth")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Feelings to practice together: \(strugglingFeelings.joined(separator: ", "))")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.9))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
}

struct QuizSessionCard: View {
    let session: QuizSession
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    private var score: QuizScore {
        session.score
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with date and grade
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dateFormatter.string(from: session.startDate))
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(session.ageRange.displayName)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(score.overallGrade)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(gradeColor)
                    
                    Text("\(Int(score.goodPercentage))%")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            
            // Score breakdown
            HStack(spacing: 16) {
                ScoreBadge(emoji: "🌟", count: score.good, color: .vibrantGreen)
                ScoreBadge(emoji: "🤔", count: score.okay, color: Color(hex: "F59E0B"))
                ScoreBadge(emoji: "🌱", count: score.bad, color: Color(hex: "06B6D4"))
                ScoreBadge(emoji: "💭", count: score.unrelated, color: Color(hex: "A855F7"))
                
                Spacer()
            }
            
            // Stories count
            HStack {
                Image(systemName: "book.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                Text("\(session.totalStories) stories")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.9))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
    
    private var gradeColor: Color {
        switch score.overallGrade {
        case "Excellent": return .vibrantGreen
        case "Good": return .vibrantBlue
        case "Fair": return Color(hex: "F59E0B")
        default: return Color(hex: "06B6D4")
        }
    }
}

struct ScoreBadge: View {
    let emoji: String
    let count: Int
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Text(emoji)
                .font(.system(size: 14))
            Text("\(count)")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(color.opacity(0.15))
        )
    }
}
