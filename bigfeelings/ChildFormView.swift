//
//  ChildFormView.swift
//  bigfeelings
//
//  Created by Christopher Law on 2025-12-07.
//

import SwiftUI

struct ChildFormView: View {
    let child: Child?
    let onSave: (Child) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var notes: String = ""
    
    var isEditing: Bool {
        child != nil
    }
    
    init(child: Child?, onSave: @escaping (Child) -> Void) {
        self.child = child
        self.onSave = onSave
        
        // Initialize state from child if editing
        if let child = child {
            _name = State(initialValue: child.name)
            _age = State(initialValue: child.age != nil ? String(child.age!) : "")
            _notes = State(initialValue: child.notes ?? "")
        } else {
            _name = State(initialValue: "")
            _age = State(initialValue: "")
            _notes = State(initialValue: "")
        }
    }
    
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
            
            Form {
                Section {
                    TextField("Name", text: $name)
                        .font(.system(size: 18, design: .rounded))
                } header: {
                    Text("About This Child")
                } footer: {
                    Text("What's their name?")
                }
                
                Section {
                    TextField("Age", text: $age)
                        .font(.system(size: 18, design: .rounded))
                        .keyboardType(.numberPad)
                } header: {
                    Text("Age")
                } footer: {
                    Text("We'll find the perfect stories based on their age (4-6, 7-9, or 10-12).")
                }
                
                Section {
                    TextEditor(text: $notes)
                        .font(.system(size: 16, design: .rounded))
                        .frame(minHeight: 100)
                } header: {
                    Text("Notes")
                } footer: {
                    Text("Optional: Add any special notes or reminders")
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(isEditing ? "Edit Child" : "Add Child")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveChild()
                }
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                .font(.system(size: 16, weight: .semibold))
            }
        }
        .onAppear {
            // Always populate fields when editing a child
            if let child = child {
                name = child.name
                if let ageValue = child.age {
                    age = String(ageValue)
                } else {
                    age = ""
                }
                notes = child.notes ?? ""
            }
        }
    }
    
    private func saveChild() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        
        let ageValue: Int? = Int(age.trimmingCharacters(in: .whitespaces))
        let trimmedNotes = notes.trimmingCharacters(in: .whitespaces)
        let notesValue = trimmedNotes.isEmpty ? nil : trimmedNotes
        
        let childToSave: Child
        if let existingChild = child {
            // Update existing child
            childToSave = Child(
                id: existingChild.id,
                name: trimmedName,
                age: ageValue,
                notes: notesValue,
                createdAt: existingChild.createdAt,
                updatedAt: Date()
            )
        } else {
            // Create new child
            childToSave = Child(
                name: trimmedName,
                age: ageValue,
                notes: notesValue
            )
        }
        
        HapticFeedbackManager.shared.impact(style: .medium)
        onSave(childToSave)
        dismiss()
    }
}
