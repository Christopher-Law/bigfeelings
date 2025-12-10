//
//  StoryLoader.swift
//  bigfeelings
//
//  Created by Christopher Law on 2025-12-07.
//

import Foundation
import os.log

enum StoryLoadingError: LocalizedError {
    case fileNotFound
    case invalidData
    case decodingFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Stories file not found in bundle"
        case .invalidData:
            return "Invalid story data format"
        case .decodingFailed(let error):
            return "Failed to decode stories: \(error.localizedDescription)"
        }
    }
}

class StoryLoader {
    static let shared = StoryLoader()
    
    private let logger = Logger(subsystem: "com.bigfeelings", category: "StoryLoader")
    
    private var stories: [Story] = []
    private var loadingError: StoryLoadingError?
    
    private init() {
        loadStories()
    }
    
    func loadStories() {
        guard let url = Bundle.main.url(forResource: "scenarios", withExtension: "json") else {
            loadingError = .fileNotFound
            logger.error("scenarios.json not found in bundle")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            stories = try decoder.decode([Story].self, from: data)
            loadingError = nil
        } catch let error as DecodingError {
            loadingError = .decodingFailed(error)
            logger.error("Error decoding stories: \(error.localizedDescription)")
        } catch {
            loadingError = .invalidData
            logger.error("Error loading stories: \(error.localizedDescription)")
        }
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
    
    func hasError() -> Bool {
        return loadingError != nil
    }
    
    func getError() -> StoryLoadingError? {
        return loadingError
    }
}

