//
//  DimmedFullScreenModifier.swift
//  Packy
//
//  Created by Mason Kim on 2/18/24.
//

import SwiftUI

extension View {
    /// Dim 을 주면서 FullScreen 으로 띄우기 위한 Modifier
    ///
    /// - description: fullScreenCover 의 아래에서 올라오는 동작을 막기 위해 transaction의 disableAnimation 이 적용되어 있어, 내부의 특정 애니메이션을 막을 수 있음. 주의해서 사용 필요
    func dimmedFullScreenCover<Content: View>(isPresented: Binding<Bool>, content: @escaping () -> Content) -> some View {
        modifier(
            DimmedFullScreenModifier(isPresented: isPresented, screenContent: content)
        )
    }
}

struct DimmedFullScreenModifier<ScreenContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    var screenContent: ScreenContent

    // 애니메이션 처리를 위한 State
    @State private var isFullScreenPresented = false

    init(isPresented: Binding<Bool>, screenContent: @escaping () -> ScreenContent) {
        self._isPresented = isPresented
        self.screenContent = screenContent()
    }

    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $isPresented) {
                Group {
                    if isFullScreenPresented {
                        ZStack {
                            // 배경 탭 가능 영역
                            Color.black.opacity(0.6)
                                .edgesIgnoringSafeArea(.all)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    isPresented = false
                                    isFullScreenPresented = false
                                    print("Background Tapped!")
                                }
                                .zIndex(0)

                            // 실제 컨텐츠
                            screenContent
                                .zIndex(1)
                        }
                        .onDisappear {
                            withAnimation(.spring) {
                                isFullScreenPresented = false
                            }
                        }
                    }
                }
                .onAppear {
                    withAnimation(.spring) {
                        isFullScreenPresented = true
                    }
                }
                .presentationBackground(.clear)
            }
            // .transaction { transaction in
            //     transaction.disablesAnimations = true
            // }
    }
}
