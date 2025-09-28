//
//  HapticFeedback.swift
//  MovieInfo
//
//  Created by Andras Szasz on 2025. 09. 28..
//


import UIKit

enum HapticFeedback {
    case light
    case medium
    case heavy
    case selection
    case notification(UINotificationFeedbackGenerator.FeedbackType)

    func trigger() {
        switch self {
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .medium:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .heavy:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        case .selection:
            UISelectionFeedbackGenerator().selectionChanged()
        case .notification(let type):
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(type)
        }
    }

    // Convenience static call
    static func trigger(_ feedback: HapticFeedback) {
        feedback.trigger()
    }
}
