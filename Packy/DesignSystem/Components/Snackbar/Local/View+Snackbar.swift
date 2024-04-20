//
//  Snackbar.swift
//  Packy
//
//  Created by Mason Kim on 1/21/24.
//

import SwiftUI

extension View {
    func snackbar(isShown: Binding<Bool>, text: String, location: SnackbarLocation = .bottom) -> some View {
        modifier(SnackbarModifier(isShown: isShown, text: text, location: location))
    }
}

struct SnackbarModifier: ViewModifier {
    @Binding var isShown: Bool
    let text: String
    var location: SnackbarLocation = .bottom
    var isFromBottom: Bool {
        location == .bottom
    }

    @State private var runningTask: Task<(), Never>?

    func body(content: Content) -> some View {
        ZStack(alignment: isFromBottom ? .bottom : .top) {
            content

            if isShown {
                Snackbar(text: text)
                    .padding(.top, 72)
                    .padding(.horizontal, 24)
                    .zIndex(1)
                    .transition(.offset(y: isFromBottom ? 250 : -250))
                    .gesture(
                        DragGesture().onEnded(onEnded)
                    )
            }
        }
        .onChange(of: isShown) {
            runningTask?.cancel()
            guard $1 else { return }
            runningTask = Task {
                try? await Task.sleep(for: .seconds(2))
                isShown = false
            }
        }
        .animation(.spring, value: isShown)
    }

    private func onEnded(value: DragGesture.Value) {
        let endY = value.translation.height
        let velocityY = value.velocity.height
        let isEnoughToClose = isFromBottom ? endY + velocityY > 100 : endY + velocityY < -100
        guard isEnoughToClose else { return }
        isShown = false
    }
}
