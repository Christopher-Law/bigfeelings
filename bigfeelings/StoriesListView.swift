//
//  StoriesListView.swift
//  bigfeelings
//
//  Created by Christopher Law on 2025-12-07.
//

import SwiftUI

struct StoriesListView: View {
    @State private var stories: [Story] = []
    @State private var selectedAge: AgeRange?
    @State private var showQuiz = false
    @State private var activeChild: Child?
    @State private var showPastQuizzes = false
    @State private var navigateToGrowth = false
    @State private var showAchievements = false
    @State private var navigateToPractice = false
    
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
            
            if selectedAge != nil {
                if stories.isEmpty {
                    VStack(spacing: 16) {
                    Text("Stories Coming Soon!")
                        .font(.system(size: 18, design: .rounded))
                        .foregroundColor(.secondary)
                        
                        if StoryLoader.shared.hasError() {
                            Text("We're having trouble loading stories right now. Please try again soon!")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Activity selection cards - matching app design language
                            VStack(spacing: 16) {
                                // Explore Stories card
                                Button(action: {
                                    HapticFeedbackManager.shared.impact(style: .medium)
                                    showQuiz = true
                                }) {
                                    ActivityCard(
                                        icon: "checkmark.circle.fill",
                                        title: "Explore Stories",
                                        subtitle: "Answer questions about feelings",
                                        iconColor: Color.vibrantGreen
                                    )
                                }
                                .buttonStyle(ActivityCardButtonStyle())
                                .accessibilityLabel("Explore Stories")
                                .accessibilityHint("Answer questions about feelings with stories for this age group")
                                
                                // Read Stories card
                                NavigationLink(destination: PracticeStoriesView(stories: stories, activeChild: activeChild)) {
                                    ActivityCard(
                                        icon: "book.fill",
                                        title: "Read Stories",
                                        subtitle: "Discover new adventures",
                                        iconColor: Color.vibrantBlue
                                    )
                                }
                                .simultaneousGesture(TapGesture().onEnded {
                                    HapticFeedbackManager.shared.impact(style: .medium)
                                })
                                .accessibilityLabel("Read Stories")
                                .accessibilityHint("Read and practice with stories")
                                
                                // Growth card (if child is selected)
                                if let child = activeChild {
                                    Button(action: {
                                        HapticFeedbackManager.shared.impact(style: .medium)
                                        showPastQuizzes = true
                                    }) {
                                        ActivityCard(
                                            icon: "chart.line.uptrend.xyaxis",
                                            title: "Growth",
                                            subtitle: "View progress",
                                            iconColor: Color.vibrantOrange
                                        )
                                    }
                                    .buttonStyle(ActivityCardButtonStyle())
                                    .accessibilityLabel("View Growth")
                                    .accessibilityHint("View \(child.name)'s growth and progress")
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .padding(.bottom, 30)
                        }
                    }
                    .scrollIndicators(.visible)
                }
            } else if activeChild == nil {
                VStack(spacing: 20) {
                    Image(systemName: "person.crop.circle.badge.questionmark")
                        .font(.system(size: 64))
                        .foregroundColor(.secondary)
                    
                    Text("Choose a Child")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Select a child to start exploring stories together")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    NavigationLink(destination: ChildrenListView()) {
                        Text("Select Child")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.vibrantGreen, Color.vibrantBlue],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                    }
                    .padding(.top, 20)
                }
            } else if activeChild?.age == nil {
                VStack(spacing: 20) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 64))
                        .foregroundColor(.orange)
                    
                    Text("Let's Set an Age")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Help us find the perfect stories for \(activeChild?.name ?? "your child") by adding their age")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    NavigationLink(destination: ChildrenListView()) {
                        Text("Edit Child")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.vibrantGreen, Color.vibrantBlue],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                    }
                    .padding(.top, 20)
                }
            } else {
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Finding stories...")
                        .font(.system(size: 18, design: .rounded))
                        .foregroundColor(.secondary)
                        .padding(.top, 16)
                }
            }
        }
        .navigationTitle(activeChild?.name ?? "Stories")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if let child = activeChild {
                    ActiveChildAvatar(child: child) {
                        showAchievements = true
                    }
                }
            }
        }
        .onAppear {
            loadStories()
        }
        .fullScreenCover(isPresented: $showQuiz) {
            if let ageRange = selectedAge {
                // Randomly select 5 stories for exploration
                let quizStories = Array(stories.shuffled().prefix(5))
                QuizView(stories: quizStories, ageRange: ageRange, child: activeChild, onNavigateToGrowth: {
                    // Navigate to Growth page after story exploration completion
                    navigateToGrowth = true
                })
            }
        }
        .sheet(isPresented: $showPastQuizzes) {
            if let child = activeChild {
                NavigationStack {
                    GrowthView(child: child)
                }
            }
        }
        .sheet(isPresented: $showAchievements) {
            if let child = activeChild {
                NavigationStack {
                    AchievementsListView(child: child)
                }
            }
        }
        .sheet(isPresented: $navigateToGrowth) {
            if let child = activeChild {
                NavigationStack {
                    GrowthView(child: child)
                }
            }
        }
    }
    
    private func loadStories() {
        activeChild = UserDefaultsManager.shared.getSelectedChild()
        
        // Get age range from the selected child's age
        if let child = activeChild, let ageRange = child.ageRange {
            selectedAge = ageRange
            UserDefaultsManager.shared.saveSelectedAge(ageRange)
            let loadedStories = StoryLoader.shared.getStories(for: ageRange)
            stories = sortStoriesWithFavoritesFirst(loadedStories, childId: child.id)
        } else {
            // Try to get from UserDefaults as fallback (for backwards compatibility)
            selectedAge = UserDefaultsManager.shared.getSelectedAge()
            if let ageRange = selectedAge {
                let loadedStories = StoryLoader.shared.getStories(for: ageRange)
                // If no child selected, don't sort by favorites
                stories = loadedStories
            } else {
                stories = []
            }
        }
    }
    
    private func sortStoriesWithFavoritesFirst(_ stories: [Story], childId: String) -> [Story] {
        let favoriteIds = Set(UserDefaultsManager.shared.getFavoriteStories(forChildId: childId))
        
        let favorites = stories.filter { favoriteIds.contains($0.id) }
        let nonFavorites = stories.filter { !favoriteIds.contains($0.id) }
        
        // Maintain original order within each group
        return favorites + nonFavorites
    }
}

struct StoryCard: View {
    let story: Story
    let isCompleted: Bool
    let isFavorited: Bool
    @State private var isPressed = false
    
    var body: some View {
        NavigationLink(destination: StoryDetailView(story: story)) {
            HStack(spacing: 16) {
                // Animal emoji (left side)
                Text(story.animalEmoji)
                    .font(.system(size: 64))
                    .accessibilityHidden(true)
                    .frame(width: 80, height: 80)
                
                // Content (right side)
                VStack(alignment: .leading, spacing: 8) {
                    // Title
                    Text(story.title)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Feeling
                    Text("Feeling: \(story.feeling)")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    // Animal name
                    Text("with \(story.animal)")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    // Badges
                    HStack(spacing: 8) {
                        if isFavorited {
                            HStack(spacing: 4) {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.red)
                                    .accessibilityLabel("Favorite")
                                Text("Favorite")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if isCompleted {
                            HStack(spacing: 4) {
                                Text("🐾")
                                    .font(.system(size: 16))
                                    .accessibilityLabel("Completed")
                                Text("Completed")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.top, 2)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, minHeight: 120)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .accessibilityLabel("\(story.title) with \(story.animal), feeling \(story.feeling)\(isFavorited ? ", favorited" : "")\(isCompleted ? ", completed" : "")")
        .accessibilityHint("Tap to read this story")
    }
}

struct ActivityCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 20) {
            // Icon with subtle background
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Chevron indicator
            Image(systemName: "chevron.right")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.secondary.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
}

struct ActivityCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

