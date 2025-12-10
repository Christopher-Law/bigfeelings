//
//  PracticeStoriesView.swift
//  bigfeelings
//
//  Created by Christopher Law on 2025-12-07.
//

import SwiftUI

struct PracticeStoriesView: View {
    let stories: [Story]
    let activeChild: Child?
    @State private var showAchievements = false
    @State private var selectedFeeling: String? = nil
    
    // Get unique feelings from stories, sorted alphabetically
    private var availableFeelings: [String] {
        Array(Set(stories.map { $0.feeling })).sorted()
    }
    
    // Filter stories based on selected feeling
    private var filteredStories: [Story] {
        if let feeling = selectedFeeling {
            return stories.filter { $0.feeling == feeling }
        }
        return stories
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
            
            if stories.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 64))
                        .foregroundColor(.secondary)
                    
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
                VStack(spacing: 0) {
                    // Feelings filter chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            // "Show All" button
                            FeelingFilterChip(
                                feeling: nil,
                                displayText: "All",
                                isSelected: selectedFeeling == nil,
                                count: stories.count
                            ) {
                                selectedFeeling = nil
                            }
                            
                            // Individual feeling chips
                            ForEach(availableFeelings, id: \.self) { feeling in
                                let count = stories.filter { $0.feeling == feeling }.count
                                FeelingFilterChip(
                                    feeling: feeling,
                                    displayText: feeling.capitalized,
                                    isSelected: selectedFeeling == feeling,
                                    count: count
                                ) {
                                    selectedFeeling = feeling
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                    }
                    .background(Color.white.opacity(0.5))
                    
                    // Stories grid
                    ScrollView {
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ],
                            spacing: 12
                        ) {
                            ForEach(filteredStories) { story in
                                StoryGridCard(
                                    story: story,
                                    isCompleted: UserDefaultsManager.shared.isStoryCompleted(story.id),
                                    isFavorited: activeChild != nil ? UserDefaultsManager.shared.isStoryFavorited(storyId: story.id, childId: activeChild!.id) : false
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                    }
                    .scrollIndicators(.visible)
                }
            }
        }
        .navigationTitle("Browse Stories")
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
        .sheet(isPresented: $showAchievements) {
            if let child = activeChild {
                NavigationStack {
                    AchievementsListView(child: child)
                }
            }
        }
    }
}

// Feeling filter chip component
struct FeelingFilterChip: View {
    let feeling: String?
    let displayText: String
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticFeedbackManager.shared.selection()
            action()
        }) {
            HStack(spacing: 6) {
                Text(displayText)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                Text("(\(count))")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color.vibrantBlue : Color.white)
                    .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// Compact grid card for stories
struct StoryGridCard: View {
    let story: Story
    let isCompleted: Bool
    let isFavorited: Bool
    @State private var isPressed = false
    
    var body: some View {
        NavigationLink(destination: StoryDetailView(story: story)) {
            VStack(spacing: 12) {
                // Animal emoji - larger and centered
                Text(story.animalEmoji)
                    .font(.system(size: 56))
                    .accessibilityHidden(true)
                    .frame(height: 70)
                
                // Title - centered
                Text(story.title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(minHeight: 44)
                
                // Feeling - centered with subtle background
                Text(story.feeling.capitalized)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.softPurple.opacity(0.15))
                    )
                
                // Favorite indicator (top right corner)
                if isFavorited {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "heart.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                                .accessibilityLabel("Favorite")
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 180)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onTapGesture {
            withAnimation {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }
        .accessibilityLabel("\(story.title), feeling \(story.feeling)\(isFavorited ? ", favorited" : "")")
        .accessibilityHint("Tap to read this story")
    }
}
