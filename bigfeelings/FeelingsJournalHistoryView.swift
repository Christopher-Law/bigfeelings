//
//  FeelingsJournalHistoryView.swift
//  bigfeelings
//
//  Created by Christopher Law on 2025-12-07.
//

import SwiftUI

struct FeelingsJournalHistoryView: View {
    let child: Child
    @State private var journalEntries: [FeelingsJournalEntry] = []
    @Environment(\.dismiss) private var dismiss
    
    private var entriesByDate: [Date: [FeelingsJournalEntry]] {
        Dictionary(grouping: journalEntries) { entry in
            Calendar.current.startOfDay(for: entry.timestamp)
        }
    }
    
    private var sortedDates: [Date] {
        entriesByDate.keys.sorted(by: >)
    }
    
    private var feelingFrequency: [(feeling: String, count: Int)] {
        let grouped = Dictionary(grouping: journalEntries) { $0.feelingName }
        return grouped.map { (feeling: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
    }
    
    var body: some View {
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
            
            if journalEntries.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "book.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.secondary)
                    
                    Text("No Check-Ins Yet")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Start tracking \(child.name)'s feelings with daily check-ins!")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // Summary stats
                        VStack(spacing: 16) {
                            Text("Emotional Patterns")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Most common feelings
                            if !feelingFrequency.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Most Common Feelings")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(.primary)
                                    
                                    ForEach(Array(feelingFrequency.prefix(5)), id: \.feeling) { item in
                                        HStack(spacing: 12) {
                                            Text(getEmojiForFeeling(item.feeling))
                                                .font(.system(size: 24))
                                            
                                            Text(item.feeling)
                                                .font(.system(size: 16, design: .rounded))
                                                .foregroundColor(.primary)
                                            
                                            Spacer()
                                            
                                            Text("\(item.count)")
                                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                                .foregroundColor(.secondary)
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white.opacity(0.9))
                                                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Timeline
                        VStack(spacing: 16) {
                            Text("Check-In History")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            ForEach(sortedDates, id: \.self) { date in
                                if let entries = entriesByDate[date] {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text(formatDate(date))
                                            .font(.system(size: 18, weight: .bold, design: .rounded))
                                            .foregroundColor(.primary)
                                        
                                        ForEach(entries) { entry in
                                            JournalEntryCard(entry: entry)
                                        }
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.white.opacity(0.9))
                                            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .navigationTitle("Journal History")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .onAppear {
            loadEntries()
        }
    }
    
    private func loadEntries() {
        journalEntries = UserDefaultsManager.shared.getJournalEntries(forChildId: child.id)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
    
    private func getEmojiForFeeling(_ feelingName: String) -> String {
        return FeelingOption.commonFeelings.first { $0.name.lowercased() == feelingName.lowercased() }?.emoji ?? "😊"
    }
}

struct JournalEntryCard: View {
    let entry: FeelingsJournalEntry
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        HStack(spacing: 16) {
            Text(entry.feelingEmoji)
                .font(.system(size: 40))
            
            VStack(alignment: .leading, spacing: 6) {
                Text(entry.feelingName)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                if let notes = entry.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Text(formatTime(entry.timestamp))
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.5))
        )
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive, action: {
                showDeleteConfirmation = true
            }) {
                Label("Delete", systemImage: "trash")
            }
        }
        .confirmationDialog("Delete this check-in?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                UserDefaultsManager.shared.deleteJournalEntry(entry)
            }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        FeelingsJournalHistoryView(child: Child(name: "Alex", age: 7))
    }
}
