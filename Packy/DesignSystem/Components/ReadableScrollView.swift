//
//  ReadableScrollView.swift
//  Packy
//
//  Created by Mason Kim on 1/30/24.
//

import SwiftUI

/// 현재 스크롤 offset을 업데이트 할 수 있는 스크롤 뷰.
public struct ReadableScrollView<Content: View>: View {
    @Namespace var offsetReadSpace

    let content: Content
    let offsetChanged: (CGFloat) -> Void
    let isPageStyle: Bool

    public init(
        isPageStyle: Bool = false,
        @ViewBuilder content: @escaping () -> Content,
        offsetChanged: @escaping (CGFloat) -> Void
    ) {
        self.content = content()
        self.isPageStyle = isPageStyle
        self.offsetChanged = offsetChanged
    }

    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                offsetReaderView

                content
            }
        }
        .if(isPageStyle) {
            $0.scrollTargetBehavior(.paging)
        }
        .coordinateSpace(name: offsetReadSpace)
        .onPreferenceChange(OffsetPreferenceKey.self) { offset in
            offsetChanged(offset)
        }
        .ignoresSafeArea(.keyboard)
    }

    var offsetReaderView: some View {
        GeometryReader { proxy in
            let yOffset = proxy.frame(in: .global).origin.y
            Color.clear
                .preference(
                    key: OffsetPreferenceKey.self,
                    value: yOffset
                )
        }
        .frame(height: 0)
    }
}

private struct OffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}
