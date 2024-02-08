//
//  BouncyButtonStyle.swift
//  Packy
//
//  Created by Mason Kim on 1/10/24.
//

import SwiftUI

extension ButtonStyle where Self == BouncyButtonStyle {
    static var bouncy: BouncyButtonStyle {
        BouncyButtonStyle()
    }

    static func bouncy(
        pressedScale: CGFloat = 0.95,
        bounceAnimation: Animation = .spring(duration: 0.3)
    ) -> BouncyButtonStyle {
        BouncyButtonStyle()
    }
}

struct BouncyButtonStyle: ButtonStyle {
    var pressedScale: CGFloat = 0.95
    var pressedOpacity: CGFloat = 0.95
    var bounceAnimation: Animation = .spring(duration: 0.3)

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed

        return VStack {
            configuration.label
                .scaleEffect(isPressed ? pressedScale : 1)
                .animation(bounceAnimation, value: isPressed)
        }
        .sensoryFeedback(.impact(flexibility: .soft), trigger: isPressed)
        .opacity(isPressed ? pressedOpacity : 1)
    }
}

#Preview {
    ScrollView {
        ForEach(0..<5, id: \.self) { id in
            Button {

            } label: {
                Rectangle()
                    .frame(width: 300, height: 300)
                    .foregroundColor(.blue)
            }
            .buttonStyle(.bouncy)
        }
    }
}
