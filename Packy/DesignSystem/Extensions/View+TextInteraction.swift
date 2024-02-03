//
//  View+TextInteraction.swift
//  Packy
//
//  Created by Mason Kim on 2/3/24.
//

import SwiftUI

struct TextInteractionAnimationValue {
    var opacity: CGFloat = 0.3
    var position: CGFloat = 0
}

extension View {
    func textInteraction(isShowing: Bool) -> some View {
        self
            .keyframeAnimator(
                initialValue: TextInteractionAnimationValue(),
                trigger: isShowing
            ) { view, value in
                view
                    .opacity(value.opacity)
                    .offset(y: -value.position)
            } keyframes: { _ in
                KeyframeTrack(\.opacity) {
                    LinearKeyframe(1, duration: 0.8)
                    LinearKeyframe(1, duration: 1.0)
                    LinearKeyframe(0, duration: 0.6)
                }
                KeyframeTrack(\.position) {
                    LinearKeyframe(10, duration: 0.8)
                    LinearKeyframe(10, duration: 1.0)
                    LinearKeyframe(0, duration: 0.6)
                }
            }
    }
}
