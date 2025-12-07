//
//  ActiveChildIndicator.swift
//  bigfeelings
//
//  Created by Christopher Law on 2025-12-07.
//

import SwiftUI

extension String {
    /// Extracts initials from a name string
    /// - Returns: Two-letter initials based on name structure:
    ///   - 2 words: first letter of first word + first letter of last word
    ///   - More than 2 words: first letter of first word + first letter of second word
    ///   - 1 word: first letter + last letter of that word
    func initials() -> String {
        let words = self.trimmingCharacters(in: .whitespaces).components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        
        guard !words.isEmpty else { return "" }
        
        if words.count == 1 {
            // Single word: first + last letter
            let word = words[0]
            if word.count > 1 {
                return String(word.prefix(1) + word.suffix(1)).uppercased()
            } else {
                return word.uppercased()
            }
        } else if words.count == 2 {
            // Two words: first letter of first + first letter of last
            return String(words[0].prefix(1) + words[1].prefix(1)).uppercased()
        } else {
            // More than 2 words: first letter of first two words
            return String(words[0].prefix(1) + words[1].prefix(1)).uppercased()
        }
    }
}

struct ActiveChildIndicator: View {
    let child: Child
    let onTap: (() -> Void)?
    
    init(child: Child, onTap: (() -> Void)? = nil) {
        self.child = child
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: {
            onTap?()
        }) {
            HStack(spacing: 8) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.vibrantBlue.opacity(0.3), Color.vibrantGreen.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)
                    
                    Text(child.name.initials())
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }
                
                // Name
                Text(child.name)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                if onTap != nil {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Compact version for navigation bar
struct ActiveChildAvatar: View {
    let child: Child
    let onAchievements: (() -> Void)?
    
    init(child: Child, onAchievements: (() -> Void)? = nil) {
        self.child = child
        self.onAchievements = onAchievements
    }
    
    var body: some View {
        let avatarView = ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.vibrantBlue.opacity(0.4), Color.vibrantGreen.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 28, height: 28)
            
            Text(child.name.initials())
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
        }
        
        if let onAchievements = onAchievements {
            Menu {
                Button(action: {
                    HapticFeedbackManager.shared.selection()
                    onAchievements()
                }) {
                    Label("View Achievements", systemImage: "trophy.fill")
                }
            } label: {
                avatarView
            }
            .accessibilityLabel("Active child: \(child.name)")
            .accessibilityHint("Tap to view achievements menu")
        } else {
            avatarView
                .accessibilityLabel("Active child: \(child.name)")
        }
    }
}
