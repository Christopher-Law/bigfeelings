//
//  FeedbackModalView.swift
//  bigfeelings
//
//  Created by Christopher Law on 2025-12-07.
//

import SwiftUI

struct FeedbackModalView: View {
    let choice: Choice
    let animalName: String
    let animalEmoji: String
    let onTryAgain: () -> Void
    let onContinue: () -> Void
    
    @State private var showConfetti = false
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    // Prevent dismissal on background tap
                }
            
            // Confetti for good choices
            if choice.type == .good && showConfetti {
                ConfettiView()
                    .allowsHitTesting(false)
            }
            
            VStack(spacing: 24) {
                Spacer()
                
                // Emoji indicator
                Text(choice.type.emoji)
                    .font(.system(size: 80))
                
                // Title
                Text(choice.type.title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                // Explanation
                Text(choice.explanation)
                    .font(.system(size: 18, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 32)
                
                // Buttons
                VStack(spacing: 16) {
                    Button(action: onTryAgain) {
                        Text("Try Again")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.vibrantBlue)
                            )
                    }
                    
                    Button(action: onContinue) {
                        Text("Continue")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.vibrantGreen)
                            )
                    }
                }
                .padding(.horizontal, 32)
                .padding(.top, 8)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 24)
            .padding(.vertical, 40)
        }
        .onAppear {
            if choice.type == .good {
                showConfetti = true
            }
        }
    }
}

