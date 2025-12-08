//
//  FeelingsJournalView.swift
//  bigfeelings
//
//  Created by Christopher Law on 2025-12-07.
//

import SwiftUI

struct FeelingsJournalView: View {
    let child: Child
    @State private var selectedFeeling: FeelingOption?
    @State private var notes: String = ""
    @State private var showHistory = false
    @State private var todaysEntry: FeelingsJournalEntry?
    @Environment(\.dismiss) private var dismiss
    
    private let feelings = FeelingOption.commonFeelings
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
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
                        // Header
                        VStack(spacing: 12) {
                            Text("How are you feeling today?")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                            
                            Text("Choose an emoji that matches how \(child.name) feels")
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        
                        // Today's entry indicator
                        if let entry = todaysEntry {
                            VStack(spacing: 8) {
                                HStack(spacing: 12) {
                                    Text(entry.feelingEmoji)
                                        .font(.system(size: 40))
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Today's Check-In")
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                            .foregroundColor(.primary)
                                        Text(entry.feelingName)
                                            .font(.system(size: 14, design: .rounded))
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.9))
                                        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                                )
                                
                                if let entryNotes = entry.notes, !entryNotes.isEmpty {
                                    Text(entryNotes)
                                        .font(.system(size: 14, design: .rounded))
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(Color.white.opacity(0.9))
                                                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                                        )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Feeling selection grid
                        if todaysEntry == nil {
                            VStack(spacing: 16) {
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible()),
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 16) {
                                    ForEach(feelings) { feeling in
                                        FeelingEmojiButton(
                                            feeling: feeling,
                                            isSelected: selectedFeeling?.id == feeling.id
                                        ) {
                                            HapticFeedbackManager.shared.impact(style: .light)
                                            selectedFeeling = feeling
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                
                                // Notes section
                                if selectedFeeling != nil {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Add a note (optional)")
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                            .foregroundColor(.primary)
                                        
                                        TextField("How are you feeling?", text: $notes, axis: .vertical)
                                            .textFieldStyle(.plain)
                                            .font(.system(size: 16, design: .rounded))
                                            .padding()
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(Color.white.opacity(0.9))
                                            )
                                            .lineLimit(3...6)
                                    }
                                    .padding(.horizontal, 20)
                                }
                                
                                // Save button
                                if selectedFeeling != nil {
                                    Button(action: {
                                        saveEntry()
                                    }) {
                                        HStack(spacing: 12) {
                                            Text("Save Check-In")
                                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 20))
                                        }
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(
                                                    LinearGradient(
                                                        colors: [Color.vibrantGreen, Color.vibrantBlue],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                                        )
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.top, 8)
                                }
                            }
                        }
                        
                        // View History button
                        Button(action: {
                            showHistory = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 16))
                                Text("View History")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                            }
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.7))
                            )
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Feelings Journal")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadTodaysEntry()
            }
            .sheet(isPresented: $showHistory) {
                NavigationStack {
                    FeelingsJournalHistoryView(child: child)
                }
            }
        }
    }
    
    private func loadTodaysEntry() {
        todaysEntry = UserDefaultsManager.shared.getTodaysJournalEntry(forChildId: child.id)
    }
    
    private func saveEntry() {
        guard let feeling = selectedFeeling else { return }
        
        let entry = FeelingsJournalEntry(
            childId: child.id,
            feelingEmoji: feeling.emoji,
            feelingName: feeling.name,
            notes: notes.isEmpty ? nil : notes,
            timestamp: Date()
        )
        
        UserDefaultsManager.shared.saveJournalEntry(entry)
        HapticFeedbackManager.shared.notification(type: .success)
        
        // Update UI
        todaysEntry = entry
        selectedFeeling = nil
        notes = ""
    }
}

struct FeelingEmojiButton: View {
    let feeling: FeelingOption
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(feeling.emoji)
                    .font(.system(size: 40))
                
                Text(feeling.name)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.vibrantBlue.opacity(0.2) : Color.white.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.vibrantBlue : Color.clear, lineWidth: 3)
                    )
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    FeelingsJournalView(child: Child(name: "Alex", age: 7))
}
