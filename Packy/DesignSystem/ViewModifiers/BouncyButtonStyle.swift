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
    var pressedOpacity: CGFloat = 0.9
    var bounceAnimation: Animation = .spring(duration: 0.3)

    @GestureState private var isPressing: Bool = false
    // @State private var isPressing: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed

        return configuration.label
                .scaleEffect(isPressed || isPressing ? pressedScale : 1)
                .animation(bounceAnimation, value: isPressed)
                .animation(bounceAnimation, value: isPressing)
                .opacity(isPressed ? pressedOpacity : 1)
                // .onTapGesture {}
                // .onLongPressGesture(perform: {}) {
                //     isPressing = $0
                // }
                .simultaneousGesture(
                    LongPressGesture()
                        .updating($isPressing) { currentState, gestureState,
                            _ in
                            gestureState = currentState
                        }
                )
    }
}

#Preview {
    ScrollView {
        ForEach(0..<5, id: \.self) { id in
            Button {
                print("taptap")
            } label: {
                Rectangle()
                    .frame(width: 300, height: 300)
                    .foregroundColor(.blue)
            }
            .buttonStyle(.bouncy)
        }
    }
}
