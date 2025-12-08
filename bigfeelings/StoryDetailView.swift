//
//  StoryDetailView.swift
//  bigfeelings
//
//  Created by Christopher Law on 2025-12-07.
//

import SwiftUI

struct StoryDetailView: View {
    let story: Story
    @StateObject private var ttsService = TextToSpeechService()
    @State private var selectedChoice: Choice?
    @State private var showFeedback = false
    @State private var showEnding = false
    @State private var shuffledChoices: [Choice] = []
    @State private var activeChild: Child?
    @State private var isFavorited: Bool = false
    @State private var showAchievements = false
    @State private var unlockedAchievement: Achievement?
    @Environment(\.dismiss) private var dismiss
    
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
            
            ScrollView {
                VStack(spacing: 24) {
                    // Animal emoji
                    Text(story.animalEmoji)
                        .font(.system(size: 80))
                        .padding(.top, 20)
                    
                    // Title
                    Text(story.title)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // With animal name
                    Text("with \(story.animal) \(story.animalEmoji)")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    // Feeling
                    Text("Feeling: \(story.feeling)")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.softPurple.opacity(0.3))
                        )
                    
                    // Story text
                    Text(story.story)
                        .font(.system(size: 18, design: .rounded))
                        .foregroundColor(.primary)
                        .lineSpacing(6)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.8))
                        )
                        .padding(.horizontal, 20)
                    
                    // Text-to-speech button
                    Button(action: {
                        HapticFeedbackManager.shared.selection()
                        if ttsService.isSpeaking {
                            ttsService.stopSpeaking()
                        } else {
                            ttsService.speak("\(story.title). \(story.story)")
                        }
                    }) {
                        HStack {
                            Image(systemName: ttsService.isSpeaking ? "stop.circle.fill" : "speaker.wave.2.fill")
                                .font(.system(size: 20))
                            Text(ttsService.isSpeaking ? "Stop Reading" : "Read Story Aloud")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(ttsService.isSpeaking ? Color.softOrange : Color.softBlue)
                        )
                    }
                    .padding(.horizontal, 20)
                    .accessibilityLabel(ttsService.isSpeaking ? "Stop reading" : "Read story aloud")
                    .accessibilityHint(ttsService.isSpeaking ? "Stops the text-to-speech narration" : "Plays the story text using text-to-speech")
                    
                    // Question
                    Text("What should \(story.animal) do?")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .padding(.top, 10)
                        .padding(.horizontal, 20)
                    
                    // Choices in single column (randomized)
                    VStack(spacing: 16) {
                        ForEach(shuffledChoices) { choice in
                            ChoiceButton(choice: choice) {
                                selectChoice(choice)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 12) {
                    if let child = activeChild {
                        Button(action: {
                            toggleFavorite(childId: child.id)
                        }) {
                            Image(systemName: isFavorited ? "heart.fill" : "heart")
                                .font(.system(size: 20))
                                .foregroundColor(isFavorited ? .red : .secondary)
                        }
                        .accessibilityLabel(isFavorited ? "Remove from favorites" : "Add to favorites")
                        .accessibilityHint("Toggles this story as a favorite")
                        
                        ActiveChildAvatar(child: child) {
                            showAchievements = true
                        }
                    }
                }
            }
        }
        .onAppear {
            verifyAgeMatch()
            // Shuffle choices when view appears
            shuffledChoices = story.choices.shuffled()
            // Load active child
            activeChild = UserDefaultsManager.shared.getSelectedChild()
            // Check favorite status
            if let child = activeChild {
                isFavorited = UserDefaultsManager.shared.isStoryFavorited(storyId: story.id, childId: child.id)
            }
        }
        .sheet(isPresented: $showFeedback) {
            if let choice = selectedChoice {
                FeedbackModalView(
                    choice: choice,
                    animalName: story.animal,
                    animalEmoji: story.animalEmoji,
                    onTryAgain: {
                        showFeedback = false
                        selectedChoice = nil
                    },
                    onContinue: {
                        showFeedback = false
                        showEnding = true
                    }
                )
            }
        }
        .sheet(isPresented: $showEnding) {
            EndingView(story: story, onBackToStories: {
                // Dismiss StoryDetailView to go back to StoriesListView
                dismiss()
            })
        }
        .sheet(isPresented: $showAchievements) {
            if let child = activeChild {
                NavigationStack {
                    AchievementsListView(child: child)
                }
            }
        }
        .achievementToast(achievement: $unlockedAchievement)
    }
    
    private func selectChoice(_ choice: Choice) {
        ttsService.stopSpeaking()
        HapticFeedbackManager.shared.selection()
        selectedChoice = choice
        showFeedback = true
    }
    
    private func verifyAgeMatch() {
        guard let selectedAge = UserDefaultsManager.shared.getSelectedAge() else {
            dismiss()
            return
        }
        
        if selectedAge != story.ageRange {
            // Age mismatch - clear and redirect
            UserDefaultsManager.shared.clearSelectedAge()
            dismiss()
        }
    }
    
    private func toggleFavorite(childId: String) {
        HapticFeedbackManager.shared.selection()
        UserDefaultsManager.shared.saveFavoriteStory(storyId: story.id, childId: childId)
        isFavorited.toggle()
        
        // Check for newly unlocked achievements (favorite-related)
        let newlyUnlocked = AchievementManager.shared.checkAchievements(forChildId: childId)
        if let firstUnlocked = newlyUnlocked.first {
            unlockedAchievement = firstUnlocked
            HapticFeedbackManager.shared.notification(type: .success)
        }
    }
}

struct ChoiceButton: View {
    let choice: Choice
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            HapticFeedbackManager.shared.selection()
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
                action()
            }
        }) {
            Text(choice.text)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, minHeight: 80)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(choiceColor, lineWidth: 2)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        .accessibilityLabel("Choice: \(choice.text)")
        .accessibilityHint("Select this choice to see feedback")
    }
    
    private var choiceColor: Color {
        switch choice.type {
        case .good: return Color.softGreen
        case .okay: return Color.warmYellow
        case .bad: return Color.softOrange
        case .unrelated: return Color.softPurple
        }
    }
}

