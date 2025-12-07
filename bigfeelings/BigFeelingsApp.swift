//
//  BigFeelingsApp.swift
//  bigfeelings
//
//  Created by Christopher Law on 2025-12-07.
//

import SwiftUI

@main
struct BigFeelingsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var selectedAge: AgeRange?
    
    var body: some View {
        NavigationStack {
            Group {
                if let age = selectedAge {
                    StoriesListView()
                } else {
                    AgeSelectionView()
                }
            }
            .onAppear {
                selectedAge = UserDefaultsManager.shared.getSelectedAge()
            }
        }
    }
}

