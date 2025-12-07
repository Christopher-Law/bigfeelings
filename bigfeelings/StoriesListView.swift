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
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.sky.opacity(0.2), Color.cream.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if let ageRange = selectedAge {
                if stories.isEmpty {
                    VStack(spacing: 16) {
                        Text("No stories available")
                            .font(.system(size: 18, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        if StoryLoader.shared.hasError() {
                            Text("There was an error loading stories. Please try again later.")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            // Past Quizzes button (if child is selected)
                            if let child = activeChild {
                                Button(action: {
                                    HapticFeedbackManager.shared.impact(style: .medium)
                                    showPastQuizzes = true
                                }) {
                                    HStack {
                                        Image(systemName: "chart.line.uptrend.xyaxis")
                                            .font(.system(size: 20))
                                        Text("Past Quizzes")
                                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    }
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.white.opacity(0.9))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(Color.vibrantBlue.opacity(0.3), lineWidth: 2)
                                            )
                                            .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
                                    )
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 10)
                                .accessibilityLabel("View Past Quizzes")
                                .accessibilityHint("View \(child.name)'s quiz history and progress")
                            }
                            
                            // Start Quiz button
                            if !stories.isEmpty {
                                Button(action: {
                                    HapticFeedbackManager.shared.impact(style: .medium)
                                    showQuiz = true
                                }) {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 24))
                                        Text("Start Quiz")
                                            .font(.system(size: 20, weight: .bold, design: .rounded))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color.vibrantGreen, Color.vibrantBlue],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                                    )
                                }
                                .padding(.horizontal, 20)
                                .accessibilityLabel("Start Quiz")
                                .accessibilityHint("Take a quiz with all stories for this age group")
                            }
                            
                            // Stories list (single column)
                            VStack(spacing: 16) {
                                ForEach(stories) { story in
                                    StoryCard(
                                        story: story,
                                        isCompleted: UserDefaultsManager.shared.isStoryCompleted(story.id),
                                        isFavorited: activeChild != nil ? UserDefaultsManager.shared.isStoryFavorited(storyId: story.id, childId: activeChild!.id) : false
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.vertical, 20)
                    }
                    .scrollIndicators(.visible)
                }
            } else if activeChild == nil {
                VStack(spacing: 20) {
                    Image(systemName: "person.crop.circle.badge.questionmark")
                        .font(.system(size: 64))
                        .foregroundColor(.secondary)
                    
                    Text("No child selected")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Please select a child to view stories")
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
                    
                    Text("Age not set")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Please set an age for \(activeChild?.name ?? "this child") to view stories")
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
                    Text("Loading stories...")
                        .font(.system(size: 18, design: .rounded))
                        .foregroundColor(.secondary)
                        .padding(.top, 16)
                }
            }
        }
        .navigationTitle("Stories")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if let child = activeChild {
                    ActiveChildAvatar(child: child)
                }
            }
        }
        .onAppear {
            loadStories()
        }
        .fullScreenCover(isPresented: $showQuiz) {
            if let ageRange = selectedAge {
                // Randomly select 5 stories for the quiz
                let quizStories = Array(stories.shuffled().prefix(5))
                QuizView(stories: quizStories, ageRange: ageRange, child: activeChild)
            }
        }
        .sheet(isPresented: $showPastQuizzes) {
            if let child = activeChild {
                NavigationStack {
                    PastQuizzesView(child: child)
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

