//
//  DimmedOverlayModifier.swift
//  Packy
//
//  Created by Mason Kim on 2/23/24.
//

import SwiftUI

extension View {
    /// Dim 을 주면서 Overlay 로 띄우기 위한 Modifier
    func dimmedOverlay<Content: View>(isPresented: Binding<Bool>, content: @escaping () -> Content) -> some View {
        modifier(
            DimmedOverlayModifier(isPresented: isPresented, screenContent: content)
        )
    }
}

struct DimmedOverlayModifier<ScreenContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    var screenContent: ScreenContent

    init(isPresented: Binding<Bool>, screenContent: @escaping () -> ScreenContent) {
        self._isPresented = isPresented
        self.screenContent = screenContent()
    }

    func body(content: Content) -> some View {
        ZStack {
            content

            Group {
                // 배경 탭 가능 영역
                Color.black.opacity(0.6)
                    .edgesIgnoringSafeArea(.all)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isPresented = false
                    }
                    .zIndex(1)

                // 실제 컨텐츠
                screenContent
                    .zIndex(2)
            }
            .opacity(isPresented ? 1 : 0)
            .allowsHitTesting(isPresented)
            .animation(.easeInOut, value: isPresented)
        }
    }
}
