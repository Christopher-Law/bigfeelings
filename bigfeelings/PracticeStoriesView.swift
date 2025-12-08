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
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(stories) { story in
                            StoryCard(
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
        .navigationTitle("Read Stories")
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
