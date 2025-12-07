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
    @State private var showAgeSelection = false
    
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
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 20) {
                        ForEach(stories) { story in
                            StoryCard(story: story, isCompleted: UserDefaultsManager.shared.isStoryCompleted(story.id))
                        }
                    }
                    .padding(20)
                }
            } else {
                VStack {
                    Text("Loading stories...")
                        .font(.system(size: 18, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Stories")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Change Age") {
                    showAgeSelection = true
                }
                .font(.system(size: 16, weight: .medium, design: .rounded))
            }
        }
        .onAppear {
            loadStories()
        }
        .sheet(isPresented: $showAgeSelection) {
            NavigationStack {
                AgeSelectionView()
            }
            .onDisappear {
                // Reload stories when age selection is dismissed
                loadStories()
            }
        }
    }
    
    private func loadStories() {
        selectedAge = UserDefaultsManager.shared.getSelectedAge()
        
        if let ageRange = selectedAge {
            stories = StoryLoader.shared.getStories(for: ageRange)
        } else {
            // No age selected, show age selection
            showAgeSelection = true
        }
    }
}

struct StoryCard: View {
    let story: Story
    let isCompleted: Bool
    @State private var isPressed = false
    
    var body: some View {
        NavigationLink(destination: StoryDetailView(story: story)) {
            VStack(spacing: 12) {
                // Animal emoji
                Text(story.animalEmoji)
                    .font(.system(size: 48))
                
                // Title
                Text(story.title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                // Feeling
                Text("Feeling: \(story.feeling)")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                
                // Animal name
                Text("with \(story.animal)")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.secondary)
                
                // Completed badge
                if isCompleted {
                    HStack(spacing: 4) {
                        Text("🐾")
                            .font(.system(size: 16))
                        Text("Completed")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 4)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

