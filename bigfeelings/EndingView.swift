//
//  EndingView.swift
//  bigfeelings
//
//  Created by Christopher Law on 2025-12-07.
//

import SwiftUI

struct EndingView: View {
    let story: Story
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToStories = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color.softGreen.opacity(0.3), Color.softBlue.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        Spacer()
                            .frame(height: 40)
                        
                        // Animal emoji
                        Text(story.animalEmoji)
                            .font(.system(size: 100))
                        
                        // Title
                        Text(story.title)
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                        
                        // Ending message
                        Text(story.endingMessage)
                            .font(.system(size: 20, design: .rounded))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(8)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 24)
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Color.white.opacity(0.9))
                            )
                            .padding(.horizontal, 24)
                        
                        // Buttons
                        VStack(spacing: 16) {
                            Button(action: {
                                navigateToStories = true
                            }) {
                                Text("Back to Stories")
                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.vibrantBlue)
                                    )
                            }
                            
                            Button(action: {
                                dismiss()
                            }) {
                                Text("Read Again")
                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.vibrantGreen)
                                    )
                            }
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 20)
                        
                        Spacer()
                            .frame(height: 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                // Mark story as completed
                UserDefaultsManager.shared.markStoryCompleted(story.id)
            }
            .navigationDestination(isPresented: $navigateToStories) {
                StoriesListView()
            }
        }
    }
}

