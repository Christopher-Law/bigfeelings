//
//  ChildrenListView.swift
//  bigfeelings
//
//  Created by Christopher Law on 2025-12-07.
//

import SwiftUI

struct ChildrenListView: View {
    @State private var children: [Child] = []
    @State private var showAddChild = false
    @State private var childToEdit: Child?
    @State private var navigateToStories = false
    @State private var showAchievements: Child?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Gradient background - matching Welcome screen style
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
                
                if children.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.secondary)
                        
                        Text("Let's Get Started!")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Add a child to begin exploring stories together")
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            presentAddChild()
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 20))
                                Text("Add Child")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
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
                        .padding(.top, 20)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(children) { child in
                                ChildCard(child: child) {
                                    selectChild(child)
                                } onEdit: {
                                    editChild(child)
                                } onDelete: {
                                    deleteChild(child)
                                } onAchievements: {
                                    showAchievements = child
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                    }
                    .scrollIndicators(.visible)
                }
            }
            .navigationTitle("Children")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentAddChild()
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
            }
            .onAppear {
                loadChildren()
            }
            .sheet(isPresented: $showAddChild) {
                NavigationStack {
                    ChildFormView(child: childToEdit) { savedChild in
                        saveChild(savedChild)
                    }
                }
                .onDisappear {
                    // Clear the child to edit when sheet is dismissed
                    childToEdit = nil
                }
            }
            .navigationDestination(isPresented: $navigateToStories) {
                StoriesListView()
            }
            .sheet(item: $showAchievements) { child in
                NavigationStack {
                    AchievementsListView(child: child)
                }
            }
        }
    }
    
    private func loadChildren() {
        children = UserDefaultsManager.shared.getChildren()
    }
    
    private func presentAddChild() {
        childToEdit = nil
        showAddChild = true
    }
    
    private func editChild(_ child: Child) {
        childToEdit = child
        showAddChild = true
    }
    
    private func saveChild(_ child: Child) {
        UserDefaultsManager.shared.saveChild(child)
        loadChildren()
        // childToEdit will be cleared in onDisappear when sheet dismisses
    }
    
    private func selectChild(_ child: Child) {
        HapticFeedbackManager.shared.impact(style: .medium)
        UserDefaultsManager.shared.saveSelectedChildId(child.id)
        
        // If child has an age range, save it and navigate to stories
        if let ageRange = child.ageRange {
            UserDefaultsManager.shared.saveSelectedAge(ageRange)
            navigateToStories = true
        } else {
            // If no age range is set, show an alert or navigate to edit
            // For now, just navigate - the StoriesListView will handle showing a message
            navigateToStories = true
        }
    }
    
    private func deleteChild(_ child: Child) {
        HapticFeedbackManager.shared.impact(style: .light)
        UserDefaultsManager.shared.deleteChild(id: child.id)
        loadChildren()
    }
}

struct ChildCard: View {
    let child: Child
    let onTap: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onAchievements: () -> Void
    
    @State private var isPressed = false
    @State private var showDeleteConfirmation = false
    @State private var showAvatarMenu = false
    
    // Generate random gradient colors based on child ID
    private var avatarGradient: LinearGradient {
        let colors = [
            Color.vibrantBlue,
            Color.vibrantGreen,
            Color.vibrantOrange,
            Color.vibrantPink,
            Color.lavender,
            Color.mint,
            Color.peach,
            Color.sky,
            Color.cream,
            Color.softPurple,
            Color.softGreen,
            Color.softOrange,
            Color.softBlue,
            Color.warmYellow
        ]
        
        // Use child ID as seed for deterministic but varied colors
        let hash = abs(child.id.hashValue)
        let color1 = colors[hash % colors.count]
        let color2 = colors[(hash / colors.count) % colors.count]
        
        return LinearGradient(
            colors: [color1.opacity(0.3), color2.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar/Icon with menu
            Menu {
                Button(action: {
                    HapticFeedbackManager.shared.selection()
                    onAchievements()
                }) {
                    Label("Achievements", systemImage: "trophy.fill")
                }
                
                Button(action: {
                    HapticFeedbackManager.shared.selection()
                    onEdit()
                }) {
                    Label("Edit", systemImage: "pencil")
                }
                
                Divider()
                
                Button(role: .destructive, action: {
                    showDeleteConfirmation = true
                }) {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(avatarGradient)
                        .frame(width: 60, height: 60)
                    
                    Text(child.name.initials())
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }
            }
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text(child.name)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                if let age = child.age {
                    Text("Age \(age)")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    if let ageRange = child.ageRange {
                        Text(ageRange.displayName)
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.secondary.opacity(0.8))
                    }
                } else {
                    Text("Age not set yet")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                if let notes = child.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            // Actions menu (ellipsis)
            Menu {
                Button(action: {
                    HapticFeedbackManager.shared.selection()
                    onEdit()
                }) {
                    Label("Edit", systemImage: "pencil")
                }
                
                Button(role: .destructive, action: {
                    showDeleteConfirmation = true
                }) {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 24))
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
                onTap()
            }
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .alert("Remove \(child.name)?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Remove", role: .destructive, action: onDelete)
        } message: {
            Text("This will remove \(child.name) from your list. You can always add them back later.")
        }
    }
}
