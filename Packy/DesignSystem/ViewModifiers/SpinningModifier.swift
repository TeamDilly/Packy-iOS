//
//  SpinningModifier.swift
//  Packy
//
//  Created by Mason Kim on 1/12/24.
//

import SwiftUI

let defaultSpinningAnimation: Animation = .easeInOut(duration: 20).repeatForever(autoreverses: false)

extension View {
    func spinning(
        animation: Animation = defaultSpinningAnimation
    ) -> some View {
        modifier(
            SpinningModifier(animation: animation)
        )
    }
}

struct SpinningModifier: ViewModifier {
    var animation: Animation
    @State private var rotationDegree: Double = 0

    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(rotationDegree))
            .onAppear {
                withAnimation(animation) {
                    rotationDegree = 360
                }
            }
    }
}
