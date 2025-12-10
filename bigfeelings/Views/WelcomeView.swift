//
//  WelcomeView.swift
//  bigfeelings
//
//  Created by Christopher Law on 2025-12-07.
//

import SwiftUI

struct WelcomeView: View {
    @State private var showChildrenList = false
    @State private var iconOpacity = 0.0
    @State private var iconScale = 0.5
    @State private var animateText = false
    @State private var floatingOffset: CGFloat = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Beautiful gradient background
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
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Animated icon
                    ZStack {
                        // Decorative circles
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.vibrantBlue.opacity(0.2), Color.vibrantGreen.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 200, height: 200)
                            .blur(radius: 20)
                            .offset(y: floatingOffset)
                            .opacity(iconOpacity)
                        
                        // Main icon
                        Image(systemName: "heart.text.square.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.vibrantBlue, Color.vibrantGreen],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                            .scaleEffect(iconScale)
                            .opacity(iconOpacity)
                            .offset(y: floatingOffset)
                    }
                    .padding(.bottom, 20)
                    
                    // Welcome text
                    VStack(spacing: 16) {
                        Text("Welcome to")
                            .font(.system(size: 28, weight: .light, design: .rounded))
                            .foregroundColor(.secondary)
                            .opacity(animateText ? 1 : 0)
                        
                        Text("Big Feelings")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .opacity(animateText ? 1 : 0)
                        
                        Text("Helping children explore and understand their emotions through stories")
                            .font(.system(size: 18, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .lineSpacing(4)
                            .opacity(animateText ? 1 : 0)
                    }
                    .offset(y: animateText ? 0 : 20)
                    .animation(
                        .spring(response: 0.8, dampingFraction: 0.7)
                        .delay(0.3),
                        value: animateText
                    )
                    
                    Spacer()
                    
                    // Get Started button
                    Button(action: {
                        HapticFeedbackManager.shared.impact(style: .medium)
                        showChildrenList = true
                    }) {
                        HStack(spacing: 12) {
                            Text("Get Started")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                            
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 22))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
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
                                .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
                        )
                    }
                    .padding(.bottom, 50)
                    .opacity(animateText ? 1 : 0)
                    .offset(y: animateText ? 0 : 20)
                    .animation(
                        .spring(response: 0.8, dampingFraction: 0.7)
                        .delay(0.6),
                        value: animateText
                    )
                }
            }
            .navigationDestination(isPresented: $showChildrenList) {
                ChildrenListView()
            }
            .onAppear {
                // Entrance animation for icon
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    iconOpacity = 1.0
                    iconScale = 1.0
                }
                
                // Start continuous floating animation after entrance
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    startFloatingAnimation()
                }
                
                // Text animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    animateText = true
                }
            }
        }
    }
    
    private func startFloatingAnimation() {
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            floatingOffset = -8
        }
    }
}

#Preview {
    WelcomeView()
}
