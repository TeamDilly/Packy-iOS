//
//  BouncyTapGesture.swift
//  Packy
//
//  Created by Mason Kim on 2/7/24.
//

import SwiftUI

extension View {
    func bouncyTapGesture(
        pressedScale: CGFloat = 0.95,
        action: @escaping () -> Void
    ) -> some View {
        modifier(BouncyTapGestureModifier(action: action))
    }
}

private struct BouncyTapGestureModifier: ViewModifier {
    var pressedScale: CGFloat = 0.95
    var bounceAnimation: Animation = .spring(duration: 0.3)
    var action: () -> Void

    @State private var isPressing: Bool = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressing ? pressedScale : 1)
            .animation(bounceAnimation, value: isPressing)
            .onTapGesture {
                HapticManager.shared.fireFeedback(.soft)
                action()
            }
            .onLongPressGesture(perform: {}) {
                isPressing = $0
            }
    }
}

#Preview {
    ScrollView {
        ForEach(0..<5, id: \.self) { id in
            Rectangle()
                .frame(width: 300, height: 300)
                .foregroundColor(.blue)
                .bouncyTapGesture {
                    print("taptap")
                }
        }
    }
}
