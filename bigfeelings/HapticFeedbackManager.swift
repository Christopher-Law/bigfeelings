//
//  HapticFeedbackManager.swift
//  bigfeelings
//
//  Created by Christopher Law on 2025-12-07.
//

import UIKit

class HapticFeedbackManager {
    static let shared = HapticFeedbackManager()
    
    // Reusable generators for better performance
    private var impactGenerators: [UIImpactFeedbackGenerator.FeedbackStyle: UIImpactFeedbackGenerator] = [:]
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()
    
    private init() {}
    
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = impactGenerators[style] ?? {
            let gen = UIImpactFeedbackGenerator(style: style)
            impactGenerators[style] = gen
            return gen
        }()
        generator.prepare()
        generator.impactOccurred()
    }
    
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        notificationGenerator.prepare()
        notificationGenerator.notificationOccurred(type)
    }
    
    func selection() {
        selectionGenerator.prepare()
        selectionGenerator.selectionChanged()
    }
}

