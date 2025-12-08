//
//  TextToSpeechService.swift
//  bigfeelings
//
//  Created by Christopher Law on 2025-12-07.
//

import AVFoundation
import Combine
import UIKit
import os.log

class TextToSpeechService: NSObject, ObservableObject {
    private let logger = Logger(subsystem: "com.bigfeelings", category: "TextToSpeechService")
    private let synthesizer = AVSpeechSynthesizer()
    @Published var isSpeaking = false
    
    // Speech settings
    private enum SpeechSettings {
        static let rate: Float = 0.45 // Child-friendly rate
        static let pitchMultiplier: Float = 1.1 // Slightly higher pitch
        static let volume: Float = 1.0
        static let language = "en-US"
    }
    
    override init() {
        super.init()
        synthesizer.delegate = self
        
        // Handle app lifecycle to stop speaking when app goes to background
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        stopSpeaking()
    }
    
    @objc private func handleAppWillResignActive() {
        stopSpeaking()
    }
    
    func speak(_ text: String) {
        stopSpeaking()
        
        // Request audio session for playback
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            logger.error("Error setting up audio session: \(error.localizedDescription)")
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: SpeechSettings.language)
        utterance.rate = SpeechSettings.rate
        utterance.pitchMultiplier = SpeechSettings.pitchMultiplier
        utterance.volume = SpeechSettings.volume
        
        synthesizer.speak(utterance)
        isSpeaking = true
    }
    
    func stopSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
        
        // Deactivate audio session when done
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            logger.error("Error deactivating audio session: \(error.localizedDescription)")
        }
    }
}

extension TextToSpeechService: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
    }
}

