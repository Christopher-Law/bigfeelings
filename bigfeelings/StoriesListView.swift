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
    @State private var showQuiz = false
    
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
                                .padding(.top, 10)
                                .accessibilityLabel("Start Quiz")
                                .accessibilityHint("Take a quiz with all stories for this age group")
                            }
                            
                            // Stories list (single column)
                            VStack(spacing: 16) {
                                ForEach(stories) { story in
                                    StoryCard(story: story, isCompleted: UserDefaultsManager.shared.isStoryCompleted(story.id))
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.vertical, 20)
                    }
                    .scrollIndicators(.visible)
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
        .fullScreenCover(isPresented: $showQuiz) {
            if let ageRange = selectedAge {
                // Randomly select 6 stories for the quiz
                let quizStories = Array(stories.shuffled().prefix(6))
                QuizView(stories: quizStories, ageRange: ageRange)
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
                    
                    // Completed badge
                    if isCompleted {
                        HStack(spacing: 4) {
                            Text("🐾")
                                .font(.system(size: 16))
                                .accessibilityLabel("Completed")
                            Text("Completed")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 2)
                    }
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
        .accessibilityLabel("\(story.title) with \(story.animal), feeling \(story.feeling)\(isCompleted ? ", completed" : "")")
        .accessibilityHint("Tap to read this story")
    }
}

