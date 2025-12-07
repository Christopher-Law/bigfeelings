//
//  QuizResultsView.swift
//  bigfeelings
//
//  Created by Christopher Law on 2025-12-07.
//

import SwiftUI
import UIKit

struct QuizResultsView: View {
    let session: QuizSession
    let onDismiss: (() -> Void)?
    let onNavigateToGrowth: (() -> Void)?
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToStories = false
    @State private var unlockedAchievement: Achievement?
    
    private let score: QuizScore
    
    init(session: QuizSession, onDismiss: (() -> Void)? = nil, onNavigateToGrowth: (() -> Void)? = nil) {
        self.session = session
        self.onDismiss = onDismiss
        self.onNavigateToGrowth = onNavigateToGrowth
        self.score = session.score
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color.softGreen.opacity(0.3), Color.softBlue.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        Spacer()
                            .frame(height: 20)
                        
                        // Celebration emoji
                        Text(celebrationEmoji)
                            .font(.system(size: 100))
                        
                        // Title
                        Text("Quiz Complete!")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                        
                        // Overall grade
                        VStack(spacing: 8) {
                            Text(score.overallGrade)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(gradeColor)
                            
                            Text("\(Int(score.goodPercentage))% Great Choices")
                                .font(.system(size: 20, weight: .medium, design: .rounded))
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal, 24)
                        
                        // Score breakdown
                        VStack(spacing: 16) {
                            ScoreRow(
                                label: "Great Choices",
                                count: score.good,
                                total: score.total,
                                color: .vibrantGreen,
                                emoji: "🌟"
                            )
                            
                            ScoreRow(
                                label: "Okay Choices",
                                count: score.okay,
                                total: score.total,
                                color: Color(hex: "F59E0B"), // Darker amber
                                emoji: "🤔"
                            )
                            
                            ScoreRow(
                                label: "Learning Moments",
                                count: score.bad,
                                total: score.total,
                                color: Color(hex: "06B6D4"), // Softer teal/cyan - growth-oriented
                                emoji: "🌱"
                            )
                            
                            ScoreRow(
                                label: "Unrelated",
                                count: score.unrelated,
                                total: score.total,
                                color: Color(hex: "A855F7"), // Darker purple
                                emoji: "💭"
                            )
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white.opacity(0.9))
                        )
                        .padding(.horizontal, 24)
                        
                        // Summary
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Summary")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text(QuizSummaryGenerator.shared.generateSummary(for: session))
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(.primary)
                                .lineSpacing(6)
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white.opacity(0.9))
                        )
                        .padding(.horizontal, 24)
                        
                        // Buttons
                        VStack(spacing: 16) {
                            Button(action: {
                                navigateToStories = true
                            }) {
                                Text("Back to Stories")
                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.vibrantBlue)
                                    )
                            }
                            
                            Button(action: {
                                shareResults()
                            }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Share Results")
                                }
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.vibrantGreen)
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 10)
                        
                        Spacer()
                            .frame(height: 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // Dismiss results view first, then trigger callback to dismiss quiz view
                        dismiss()
                        // Small delay to ensure results view dismisses first
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            onDismiss?()
                            // Navigate to Growth after dismissing quiz view
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onNavigateToGrowth?()
                            }
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToStories) {
                StoriesListView()
            }
            .onAppear {
                // Record activity for streak and check achievements
                if let childId = session.childId {
                    AchievementManager.shared.recordActivity(forChildId: childId)
                    
                    // Check for newly unlocked achievements with a small delay to ensure view is ready
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        let newlyUnlocked = AchievementManager.shared.checkAchievements(forChildId: childId)
                        if let firstUnlocked = newlyUnlocked.first {
                            unlockedAchievement = firstUnlocked
                            HapticFeedbackManager.shared.notification(type: .success)
                        }
                    }
                }
            }
            .achievementToast(achievement: $unlockedAchievement)
        }
    }
    
    private var celebrationEmoji: String {
        switch score.overallGrade {
        case "Excellent": return "🎉"
        case "Good": return "🌟"
        case "Fair": return "👍"
        default: return "🌱"
        }
    }
    
    private var gradeColor: Color {
        switch score.overallGrade {
        case "Excellent": return .vibrantGreen
        case "Good": return .vibrantBlue
        case "Fair": return Color(hex: "F59E0B") // Darker amber/orange
        default: return Color(hex: "06B6D4") // Softer teal/cyan - growth-oriented
        }
    }
    
    private func shareResults() {
        let summary = QuizSummaryGenerator.shared.generateSummary(for: session)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        let shareText = """
        Quiz Results - \(session.ageRange.displayName)
        Completed: \(dateFormatter.string(from: session.startDate))
        
        Score: \(score.overallGrade) (\(Int(score.goodPercentage))%)
        Great Choices: \(score.good)/\(score.total)
        
        \(summary)
        """
        
        let activityVC = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        // Configure for iPad
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
        }
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
    }
}

struct ScoreRow: View {
    let label: String
    let count: Int
    let total: Int
    let color: Color
    let emoji: String
    
    private var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(count) / Double(total) * 100
    }
    
    var body: some View {
        HStack {
            Text(emoji)
                .font(.system(size: 24))
            
            Text(label)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.primary)
            
            Spacer()
            
            Text("\(count)/\(total)")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(color)
            
            Text("(\(Int(percentage))%)")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.primary.opacity(0.7))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}
