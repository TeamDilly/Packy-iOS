//
//  GlobalSnackbar.swift
//  Packy
//
//  Created by Mason Kim on 4/20/24.
//

import SwiftUI

// MARK: - View Modifier

extension View {
    /// 글로벌하게 사용하기 위한 Snackbar 설정 - App 단에서 1번만 등록하면 됨
    func globalSnackbar() -> some View {
        modifier(GlobalSnackbarModifier())
    }
}

fileprivate struct GlobalSnackbarModifier: ViewModifier {
    @ObservedObject private var manager: SnackbarManager = .shared

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if manager.isPresented {
                    Snackbar(text: manager.configuration.text)
                        .padding(.top, 72)
                        .padding(.horizontal, 24)
                        .zIndex(1)
                        .transition(
                            .offset(
                                y: manager.configuration.isFromBottom ? 250 : -250
                            )
                        )
                        .if(manager.configuration.isDismissGestureEnabled) {
                            $0.gesture(
                                DragGesture().onEnded(onEnded)
                            )
                        }
                }
            }
            .animation(.spring, value: manager.isPresented)
            .animation(.spring, value: manager.configuration)
    }

    private func onEnded(value: DragGesture.Value) {
        let endY = value.translation.height
        let velocityY = value.velocity.height

        if manager.configuration.isFromBottom {
            guard endY + velocityY > 100 else { return }
        } else {
            guard endY + velocityY < -100 else { return }
        }


        manager.dismiss()
    }
}


// MARK: - Preview

#Preview {
    VStack {
        Text("Hello")

        Button("Show") {
            SnackbarManager.shared.show(configuration: .init(text: "Test1"))
        }

        Button("Show Another") {
            SnackbarManager.shared.show(
                configuration: .init(
                    text: "Text"
                )
            )
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.gray)
    .globalSnackbar()
}
