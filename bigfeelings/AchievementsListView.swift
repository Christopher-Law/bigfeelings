//
//  AchievementsListView.swift
//  bigfeelings
//
//  Created by Christopher Law on 2025-12-07.
//

import SwiftUI

struct AchievementsListView: View {
    let child: Child
    @State private var achievements: [Achievement] = []
    @State private var selectedCategory: AchievementCategory? = nil
    @Environment(\.dismiss) private var dismiss
    
    private var filteredAchievements: [Achievement] {
        if let category = selectedCategory {
            return achievements.filter { $0.category == category }
        }
        return achievements
    }
    
    private var unlockedCount: Int {
        achievements.filter { $0.isUnlocked }.count
    }
    
    private var currentStreak: Int {
        AchievementManager.shared.getCurrentStreak(forChildId: child.id)
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
            
            ScrollView {
                VStack(spacing: 24) {
                    // Streak display
                    StreakCard(streak: currentStreak)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    
                    // Progress summary
                    ProgressSummaryCard(unlocked: unlockedCount, total: achievements.count)
                        .padding(.horizontal, 20)
                    
                    // Category filter
                    CategoryFilterView(selectedCategory: $selectedCategory)
                        .padding(.horizontal, 20)
                    
                    // Achievements grid
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(filteredAchievements) { achievement in
                            AchievementCard(achievement: achievement)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            loadAchievements()
        }
    }
    
    private func loadAchievements() {
        achievements = AchievementManager.shared.getAchievements(forChildId: child.id)
    }
}

struct StreakCard: View {
    let streak: Int
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "flame.fill")
                .font(.system(size: 32))
                .foregroundColor(.orange)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Current Streak")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.secondary)
                
                Text("\(streak) day\(streak == 1 ? "" : "s")")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.9))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
}

struct ProgressSummaryCard: View {
    let unlocked: Int
    let total: Int
    
    private var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(unlocked) / Double(total) * 100
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Progress")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Spacer()
                Text("\(unlocked)/\(total)")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 12)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [Color.vibrantGreen, Color.vibrantBlue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * (percentage / 100), height: 12)
                }
            }
            .frame(height: 12)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.9))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
}

struct CategoryFilterView: View {
    @Binding var selectedCategory: AchievementCategory?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CategoryButton(
                    title: "All",
                    isSelected: selectedCategory == nil
                ) {
                    selectedCategory = nil
                }
                
                ForEach(AchievementCategory.allCases, id: \.self) { category in
                    CategoryButton(
                        title: category.displayName,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.vibrantBlue : Color.white.opacity(0.9))
                )
        }
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        achievement.isUnlocked ?
                        LinearGradient(
                            colors: [Color.vibrantBlue.opacity(0.3), Color.vibrantGreen.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 28))
                    .foregroundColor(achievement.isUnlocked ? .primary : .gray)
                
                if !achievement.isUnlocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .offset(x: 20, y: 20)
                }
            }
            
            // Title
            Text(achievement.title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(achievement.isUnlocked ? .primary : .gray)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            // Progress bar
            if !achievement.isUnlocked {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 6)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.vibrantBlue.opacity(0.5))
                            .frame(width: geometry.size.width * (achievement.progressPercentage / 100), height: 6)
                    }
                }
                .frame(height: 6)
                
                Text("\(achievement.currentProgress)/\(achievement.requirement)")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(.secondary)
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.vibrantGreen)
                    Text("Unlocked")
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(achievement.isUnlocked ? Color.white.opacity(0.9) : Color.white.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(achievement.isUnlocked ? Color.vibrantBlue.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .black.opacity(achievement.isUnlocked ? 0.08 : 0.04), radius: 4, x: 0, y: 2)
        )
    }
}
