//
//  StoryLoader.swift
//  bigfeelings
//
//  Created by Christopher Law on 2025-12-07.
//

import Foundation

class StoryLoader {
    static let shared = StoryLoader()
    
    private var stories: [Story] = []
    
    private init() {
        loadStories()
    }
    
    func loadStories() {
        guard let url = Bundle.main.url(forResource: "scenarios", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let loadedStories = try? JSONDecoder().decode([Story].self, from: data) else {
            print("Error loading stories from scenarios.json")
            return
        }
        stories = loadedStories
    }
    
    func getStories(for ageRange: AgeRange) -> [Story] {
        return stories.filter { $0.ageRange == ageRange }
    }
    
    func getStory(by id: String) -> Story? {
        return stories.first { $0.id == id }
    }
    
    func getAllStories() -> [Story] {
        return stories
    }
}

