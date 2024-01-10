//
//  HapticManager.swift
//  Packy
//
//  Created by Mason Kim on 1/10/24.
//

import SwiftUI

// MARK: - Typealias

typealias NotificationHaptic = UINotificationFeedbackGenerator.FeedbackType
typealias FeedbackHaptic = UIImpactFeedbackGenerator.FeedbackStyle
typealias FeedbackHapticGenerators = [FeedbackHaptic: UIImpactFeedbackGenerator]

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
    func fireFeedback(_ type: FeedbackHaptic) {
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
        FeedbackHaptic.allCases.reduce(into: FeedbackHapticGenerators()) {
            $0[$1] = UIImpactFeedbackGenerator(style: $1)
        }
    }
}

// MARK: - FeedbackHaptic AllCases

extension FeedbackHaptic {
    static var allCases: [FeedbackHaptic] {
        [
            FeedbackHaptic.heavy,
            FeedbackHaptic.medium,
            FeedbackHaptic.light,
            FeedbackHaptic.rigid,
            FeedbackHaptic.soft
        ]
    }
}
