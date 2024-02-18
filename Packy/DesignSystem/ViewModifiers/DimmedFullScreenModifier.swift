//
//  DimmedFullScreenModifier.swift
//  Packy
//
//  Created by Mason Kim on 2/18/24.
//

import SwiftUI

extension View {
    func dimmedFullScreenCover<Content: View>(isPresented: Binding<Bool>, content: @escaping () -> Content) -> some View {
        modifier(
            DimmedFullScreenModifier(isPresented: isPresented, screenContent: content)
        )
    }
}

struct DimmedFullScreenModifier<ScreenContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    var screenContent: () -> ScreenContent

    @State private var isFullScreenPresented = false

    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $isPresented) {
                Group {
                    if isFullScreenPresented {
                        ZStack {
                            // 배경 탭 가능 영역
                            Color.black.opacity(0.5)
                                .edgesIgnoringSafeArea(.all)
                                .onTapGesture {
                                    isPresented = false
                                }

                            // 실제 컨텐츠
                            screenContent()
                        }
                        .onDisappear {
                            isFullScreenPresented = false
                        }
                    }
                }
                .animation(.spring, value: isFullScreenPresented)
                .onAppear {
                    isFullScreenPresented = true
                }
                .presentationBackground(.black.opacity(0.6))
                .transition(.opacity)
            }
            .transaction { transaction in
                transaction.disablesAnimations = true
                transaction.animation = .spring
            }
            .animation(.spring, value: isFullScreenPresented)
    }
}
