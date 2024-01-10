//
//  BouncyTapGestureModifier.swift
//  Packy
//
//  Created by Mason Kim on 1/10/24.
//

import SwiftUI

extension View {
    /// 사용자 탭에 따라 뷰의 사이즈를 작아졌다 커졌다 하게 하는 `tap gesture`
    ///
    /// - Parameters:
    ///   - pressedScale: 눌려서 작아질 때의 크기 (기본값 0.95)
    ///   - bounceAnimation: 눌렸을 때의 애니메이션
    func bouncyTapGesture(
        pressedScale: CGFloat = 0.95,
        bounceAnimation: Animation = .spring,
        isEnableBounce: Bool = true,
        action: @escaping () -> Void
    ) -> some View {
        modifier(
            BouncyTapGestureModifier(
                pressedScale: pressedScale,
                bounceAnimation: bounceAnimation,
                isEnableBounce: isEnableBounce,
                action: action
            )
        )
    }
}

// MARK: - View Modifier

private struct BouncyTapGestureModifier: ViewModifier {
    let pressedScale: CGFloat
    let bounceAnimation: Animation
    let isEnableBounce: Bool
    let action: () -> Void

    @State private var isPressed: Bool = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? pressedScale : 1)
            .animation(bounceAnimation, value: isPressed)
            .onTapGesture { action() }
            .onLongPressGesture(
                minimumDuration: .infinity,
                pressing: { pressing in
                    guard isEnableBounce else { return }
                    isPressed = pressing
                },
                perform: {}
            )
    }
}

#Preview {
    ScrollView {
        ForEach(0..<5, id: \.self) { id in
            Rectangle()
                .bouncyTapGesture {
                    print("Action \(id)!")
                }
                .frame(width: 300, height: 300)
                .foregroundColor(.blue)
        }
    }
}
