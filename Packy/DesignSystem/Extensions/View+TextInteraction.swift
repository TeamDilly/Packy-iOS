//
//  View+TextInteraction.swift
//  Packy
//
//  Created by Mason Kim on 2/3/24.
//

import SwiftUI

extension View {
    /// 나타났다 사라지는 텍스트 인터액션 표시 (onAppear 에서 즉시 표시되고, duration은 2.4초임)
    func textInteraction() -> some View {
        modifier(TextInteractionViewModifier())
    }
}

private struct TextInteractionAnimationValue {
    var opacity: CGFloat = 0.3
    var position: CGFloat = 0
}

private struct TextInteractionViewModifier: ViewModifier {
    @State private var isShowing: Bool = false

    func body(content: Content) -> some View {
        content
            .onAppear {
                isShowing = true
            }
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
