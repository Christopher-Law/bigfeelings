//
//  AppLifecycleHandler.swift
//  bigfeelings
//
//  Created by Christopher Law on 2025-12-07.
//

import SwiftUI
import Combine
import UIKit

class AppLifecycleHandler: ObservableObject {
    @Published var isActive = true
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Handle app lifecycle events
        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                self?.isActive = false
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.isActive = true
            }
            .store(in: &cancellables)
    }
}

