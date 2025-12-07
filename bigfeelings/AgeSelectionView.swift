//
//  AgeSelectionView.swift
//  bigfeelings
//
//  Created by Christopher Law on 2025-12-07.
//

import SwiftUI

struct AgeSelectionView: View {
    @State private var selectedAge: AgeRange?
    @State private var navigateToStories = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [Color.lavender.opacity(0.3), Color.mint.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Title
                VStack(spacing: 10) {
                    Text("When I Feel...")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("I Can...")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Choose your age group to begin")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
                .padding(.bottom, 20)
                
                // Age cards
                VStack(spacing: 20) {
                    AgeCard(ageRange: .fourToSix, isSelected: selectedAge == .fourToSix) {
                        selectAge(.fourToSix)
                    }
                    
                    AgeCard(ageRange: .sevenToNine, isSelected: selectedAge == .sevenToNine) {
                        selectAge(.sevenToNine)
                    }
                    
                    AgeCard(ageRange: .tenToTwelve, isSelected: selectedAge == .tenToTwelve) {
                        selectAge(.tenToTwelve)
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
        .navigationDestination(isPresented: $navigateToStories) {
            StoriesListView()
        }
    }
    
    private func selectAge(_ ageRange: AgeRange) {
        selectedAge = ageRange
        UserDefaultsManager.shared.saveSelectedAge(ageRange)
        
        // Gentle animation delay before navigation or dismissal
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Try to dismiss (works if in sheet, no-op if root view)
            dismiss()
            // Navigate if we're the root view (navigationDestination handles this)
            navigateToStories = true
        }
    }
}

struct AgeCard: View {
    let ageRange: AgeRange
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
                action()
            }
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(ageRange.displayName)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(ageRangeDescription)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.primary)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(backgroundColor)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : (isSelected ? 1.05 : 1.0))
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
    
    private var backgroundColor: Color {
        switch ageRange {
        case .fourToSix: return Color.lavender
        case .sevenToNine: return Color.mint
        case .tenToTwelve: return Color.peach
        }
    }
    
    private var ageRangeDescription: String {
        switch ageRange {
        case .fourToSix: return "Stories about sharing, bedtime, and making friends"
        case .sevenToNine: return "Stories about school, friendships, and growing up"
        case .tenToTwelve: return "Stories about challenges, choices, and understanding yourself"
        }
    }
}

