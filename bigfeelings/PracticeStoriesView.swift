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
            // Background
            LinearGradient(
                colors: [Color.sky.opacity(0.2), Color.cream.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if stories.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 64))
                        .foregroundColor(.secondary)
                    
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
        .navigationTitle("Practice Stories")
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
