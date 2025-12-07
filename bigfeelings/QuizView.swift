//
//  QuizView.swift
//  bigfeelings
//
//  Created by Christopher Law on 2025-12-07.
//

import SwiftUI

struct QuizView: View {
    let stories: [Story]
    let ageRange: AgeRange
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentIndex = 0
    @State private var answers: [QuizAnswer] = []
    @State private var selectedChoice: Choice?
    @State private var showResults = false
    @State private var quizSession: QuizSession?
    @State private var completedSession: QuizSession?
    @State private var shuffledChoicesByStory: [String: [Choice]] = [:]
    
    private var currentStory: Story? {
        guard currentIndex < stories.count else { return nil }
        return stories[currentIndex]
    }
    
    private var progress: Double {
        guard !stories.isEmpty else { return 0 }
        return Double(currentIndex) / Double(stories.count)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color.cream.opacity(0.3), Color.sky.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if let story = currentStory {
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: 24) {
                                // Progress indicator
                                VStack(spacing: 8) {
                                    HStack {
                                        Text("Story \(currentIndex + 1) of \(stories.count)")
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                            .foregroundColor(.secondary)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 20)
                                    
                                    GeometryReader { geometry in
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.gray.opacity(0.2))
                                                .frame(height: 8)
                                            
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.vibrantBlue)
                                                .frame(width: geometry.size.width * progress, height: 8)
                                        }
                                    }
                                    .frame(height: 8)
                                    .padding(.horizontal, 20)
                                }
                                .padding(.top, 20)
                                .id("top")
                                
                                // Animal emoji
                                Text(story.animalEmoji)
                                    .font(.system(size: 80))
                                
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
                                
                                // Question
                                Text("What should \(story.animal) do?")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                    .padding(.top, 10)
                                    .padding(.horizontal, 20)
                                
                                // Choices in single column (randomized)
                                VStack(spacing: 16) {
                                    ForEach(shuffledChoices(for: story)) { choice in
                                        QuizChoiceButton(
                                            choice: choice,
                                            isSelected: false,
                                            isDisabled: selectedChoice != nil
                                        ) {
                                            selectChoice(choice, for: story)
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 30)
                            }
                        }
                        .onChange(of: currentIndex) {
                            // Scroll to top when moving to next question
                            DispatchQueue.main.async {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    proxy.scrollTo("top", anchor: .top)
                                }
                            }
                        }
                        .onAppear {
                            // Ensure scroll is at top when view appears
                            DispatchQueue.main.async {
                                proxy.scrollTo("top", anchor: .top)
                            }
                        }
                    }
                } else {
                    // Loading or error state
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading quiz...")
                            .font(.system(size: 18, design: .rounded))
                            .foregroundColor(.secondary)
                            .padding(.top, 16)
                    }
                }
            }
            .navigationTitle("Quiz Mode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Exit") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                startQuiz()
            }
            .fullScreenCover(isPresented: $showResults) {
                if let session = completedSession {
                    QuizResultsView(session: session, onDismiss: {
                        showResults = false
                        dismiss()
                    })
                } else if let session = quizSession {
                    QuizResultsView(session: session, onDismiss: {
                        showResults = false
                        dismiss()
                    })
                } else {
                    // Fallback - shouldn't happen, but just in case
                    VStack {
                        Text("Error loading results")
                            .font(.system(size: 18, design: .rounded))
                        Button("Close") {
                            showResults = false
                            dismiss()
                        }
                    }
                }
            }
        }
    }
    
    private func startQuiz() {
        let sessionId = UUID().uuidString
        quizSession = QuizSession(
            id: sessionId,
            ageRange: ageRange,
            startDate: Date(),
            endDate: nil,
            answers: []
        )
        
        // Pre-shuffle choices for all stories
        for story in stories {
            shuffledChoicesByStory[story.id] = story.choices.shuffled()
        }
    }
    
    private func shuffledChoices(for story: Story) -> [Choice] {
        // Return shuffled choices for this story, or fallback to original order
        return shuffledChoicesByStory[story.id] ?? story.choices
    }
    
    private func selectChoice(_ choice: Choice, for story: Story) {
        // Prevent multiple selections
        guard selectedChoice == nil else { return }
        
        HapticFeedbackManager.shared.selection()
        selectedChoice = choice
        
        // Save answer immediately
        let answer = QuizAnswer(
            storyId: story.id,
            storyTitle: story.title,
            feeling: story.feeling,
            selectedChoiceId: choice.id,
            selectedChoiceType: choice.type,
            timestamp: Date()
        )
        answers.append(answer)
        
        // Update session with current answers
        if var session = quizSession {
            quizSession = QuizSession(
                id: session.id,
                ageRange: session.ageRange,
                startDate: session.startDate,
                endDate: nil,
                answers: answers
            )
        }
        
        // Automatically advance after a brief delay to show selection
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            nextStory()
        }
    }
    
    private func nextStory() {
        guard let story = currentStory,
              selectedChoice != nil else { return }
        
        HapticFeedbackManager.shared.impact(style: .light)
        
        // Move to next story or finish
        if currentIndex < stories.count - 1 {
            currentIndex += 1
            selectedChoice = nil
        } else {
            // Last question answered, finish quiz
            finishQuiz()
        }
    }
    
    private func finishQuiz() {
        // Ensure we have the current story's answer saved
        // (It should already be saved in selectChoice, but double-check)
        if let story = currentStory,
           let choice = selectedChoice,
           !answers.contains(where: { $0.storyId == story.id }) {
            // Answer wasn't saved, save it now
            let answer = QuizAnswer(
                storyId: story.id,
                storyTitle: story.title,
                feeling: story.feeling,
                selectedChoiceId: choice.id,
                selectedChoiceType: choice.type,
                timestamp: Date()
            )
            answers.append(answer)
        }
        
        guard let session = quizSession else { return }
        
        // Complete the session with all answers
        let sessionToComplete = QuizSession(
            id: session.id,
            ageRange: session.ageRange,
            startDate: session.startDate,
            endDate: Date(),
            answers: answers
        )
        
        // Save to UserDefaults
        UserDefaultsManager.shared.saveQuizSession(sessionToComplete)
        
        // Update both state variables
        quizSession = sessionToComplete
        completedSession = sessionToComplete
        
        // Show results
        showResults = true
    }
}

struct QuizChoiceButton: View {
    let choice: Choice
    let isSelected: Bool
    let isDisabled: Bool
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            guard !isDisabled else { return }
            HapticFeedbackManager.shared.selection()
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
                action()
            }
        }) {
            HStack {
                Text(choice.text)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(isDisabled ? .secondary : .primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(choiceColor)
                        .font(.system(size: 24))
                }
            }
            .frame(maxWidth: .infinity, minHeight: 80)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? choiceColor.opacity(0.1) : (isDisabled ? Color.gray.opacity(0.1) : Color.white))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(choiceColor, lineWidth: isSelected ? 3 : 2)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isDisabled)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        .accessibilityLabel("Choice: \(choice.text)")
        .accessibilityHint(isDisabled ? "Choice already selected" : "Select this choice")
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
