//
//  PastQuizzesView.swift
//  bigfeelings
//
//  Created by Christopher Law on 2025-12-07.
//

import SwiftUI
import Charts

struct PastQuizzesView: View {
    let child: Child
    @State private var quizSessions: [QuizSession] = []
    
    private var completedSessions: [QuizSession] {
        quizSessions.filter { $0.isCompleted }
    }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.sky.opacity(0.2), Color.cream.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if completedSessions.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 64))
                        .foregroundColor(.secondary)
                    
                    Text("No Past Quizzes")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Complete quizzes to see \(child.name)'s progress here")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        // Emotional Intelligence Growth Chart
                        EmotionalIntelligenceChart(sessions: completedSessions)
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                        
                        // Progress overview card
                        if completedSessions.count > 1 {
                            ProgressOverviewCard(sessions: completedSessions)
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
        .navigationTitle("Past Quizzes")
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

struct EmotionalIntelligenceChart: View {
    let sessions: [QuizSession]
    
    private var chartData: [(date: Date, score: Double)] {
        let calendar = Calendar.current
        
        // Group sessions by day (normalize to start of day)
        let groupedByDay = Dictionary(grouping: sessions) { session in
            calendar.startOfDay(for: session.startDate)
        }
        
        // Calculate average score for each day
        return groupedByDay
            .map { (date, daySessions) in
                let averageScore = daySessions.reduce(0.0) { $0 + $1.score.goodPercentage } / Double(daySessions.count)
                return (date: date, score: averageScore)
            }
            .sorted { $0.date < $1.date }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
    
    private var minScore: Double {
        let scores = chartData.map { $0.score }
        let min = scores.min() ?? 0
        return max(0, min - 10)
    }
    
    private var maxScore: Double {
        let scores = chartData.map { $0.score }
        let max = scores.max() ?? 100
        return min(100, max + 10)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Emotional Intelligence Growth")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            if #available(iOS 16.0, *) {
                if chartData.count > 1 {
                    Chart {
                        // Area mark for gradient fill
                        ForEach(Array(chartData.enumerated()), id: \.offset) { index, data in
                            AreaMark(
                                x: .value("Date", data.date, unit: .day),
                                y: .value("Score", data.score)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.vibrantBlue.opacity(0.3), Color.vibrantBlue.opacity(0.05)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .interpolationMethod(.catmullRom)
                        }
                        
                        // Line mark for the progression line
                        ForEach(Array(chartData.enumerated()), id: \.offset) { index, data in
                            LineMark(
                                x: .value("Date", data.date, unit: .day),
                                y: .value("Score", data.score)
                            )
                            .foregroundStyle(Color.vibrantBlue)
                            .lineStyle(StrokeStyle(lineWidth: 3))
                            .interpolationMethod(.catmullRom)
                        }
                        
                        // Point marks for data points
                        ForEach(Array(chartData.enumerated()), id: \.offset) { index, data in
                            PointMark(
                                x: .value("Date", data.date, unit: .day),
                                y: .value("Score", data.score)
                            )
                            .foregroundStyle(Color.vibrantBlue)
                            .symbolSize(60)
                        }
                    }
                    .chartYScale(domain: minScore...maxScore)
                    .chartXAxis {
                        AxisMarks(values: .automatic(desiredCount: min(5, chartData.count))) { value in
                            AxisGridLine()
                            AxisValueLabel(format: .dateTime.month().day())
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading, values: .automatic(desiredCount: 5)) { value in
                            AxisGridLine()
                            AxisValueLabel {
                                if let intValue = value.as(Double.self) {
                                    Text("\(Int(intValue))%")
                                        .font(.system(size: 11, design: .rounded))
                                }
                            }
                        }
                    }
                    .frame(height: 200)
                } else if chartData.count == 1 {
                    // Single data point - show a simple display
                    VStack(spacing: 12) {
                        HStack {
                            Spacer()
                            VStack(spacing: 4) {
                                Text("\(Int(chartData[0].score))%")
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                    .foregroundColor(.vibrantBlue)
                                Text("Current Score")
                                    .font(.system(size: 14, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        Text("Complete more quizzes to see your growth chart!")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(height: 200)
                }
            } else {
                // Fallback for iOS < 16
                VStack(spacing: 12) {
                    Text("Chart requires iOS 16+")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                    if chartData.count == 1 {
                        Text("Current Score: \(Int(chartData[0].score))%")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                }
                .frame(height: 200)
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

struct ProgressOverviewCard: View {
    let sessions: [QuizSession]
    
    private var averageScore: Double {
        guard !sessions.isEmpty else { return 0 }
        let total = sessions.reduce(0.0) { $0 + $1.score.goodPercentage }
        return total / Double(sessions.count)
    }
    
    private var trend: String {
        guard sessions.count >= 2 else { return "📊" }
        
        // Compare most recent 3 with previous 3 (avoiding overlap)
        let takeCount = min(3, sessions.count / 2)
        let recent = Array(sessions.prefix(takeCount)).map { $0.score.goodPercentage }
        let older = Array(sessions.suffix(takeCount)).map { $0.score.goodPercentage }
        
        // If we don't have enough sessions, compare first vs last
        guard !recent.isEmpty && !older.isEmpty else { return "📊" }
        
        let recentAvg = recent.reduce(0, +) / Double(recent.count)
        let olderAvg = older.reduce(0, +) / Double(older.count)
        
        if recentAvg > olderAvg + 5 {
            return "📈 Improving"
        } else if recentAvg < olderAvg - 5 {
            return "📉 Needs Support"
        } else {
            return "➡️ Steady"
        }
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
                    Text("Total Quizzes")
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
            
            HStack {
                Text(trend)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
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
