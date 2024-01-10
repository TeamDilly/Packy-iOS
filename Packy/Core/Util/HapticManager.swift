//
//  HapticManager.swift
//  Packy
//
//  Created by Mason Kim on 1/10/24.
//

import SwiftUI

// MARK: - Typealias

typealias NotificationHaptic = UINotificationFeedbackGenerator.FeedbackType
typealias FeedbackHapticGenerators = [FeedbackStyle: UIImpactFeedbackGenerator]

// MARK: - FeedbackStyle

enum FeedbackStyle: CaseIterable {
    case heavy
    case medium
    case light
    case rigid
    case soft

    var value: UIImpactFeedbackGenerator.FeedbackStyle {
        switch self {
        case .heavy:    return .heavy
        case .medium:   return .medium
        case .light:    return .light
        case .rigid:    return .rigid
        case .soft:     return .soft
        }
    }
}

// MARK: - HapticManager

@MainActor
final class HapticManager {
    static let shared = HapticManager()
    private init() {
        self.feedbackHapticGenerators = feedbackGenerators()
    }

    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private var feedbackHapticGenerators: FeedbackHapticGenerators = [:]

    @MainActor
    func fireFeedback(_ type: FeedbackStyle) {
        feedbackHapticGenerators[type]?.prepare()
        feedbackHapticGenerators[type]?.impactOccurred()
    }

    @MainActor
    func fireNotification(_ type: NotificationHaptic) {
        notificationGenerator.prepare()
        notificationGenerator.notificationOccurred(type)
    }

    @MainActor
    func selectionChanged() {
        selectionGenerator.selectionChanged()
    }

    private func feedbackGenerators() -> FeedbackHapticGenerators {
        FeedbackStyle.allCases.reduce(into: FeedbackHapticGenerators()) {
            $0[$1] = UIImpactFeedbackGenerator(style: $1.value)
        }
    }
}
