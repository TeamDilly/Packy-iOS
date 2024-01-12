//
//  CarouselView.swift
//  Packy
//
//  Created by Mason Kim on 1/12/24.
//

import SwiftUI

// 가로 사이즈 - (width / 2)
struct CarouselView<Content: View>: View {
    private let itemWidth: CGFloat
    private let itemPadding: CGFloat
    private let content: Content

    init(
        itemWidth: CGFloat,
        itemPadding: CGFloat,
        @ViewBuilder content: () -> Content
    ) {
        self.itemWidth = itemWidth
        self.itemPadding = itemPadding
        self.content = content()
    }

    var body: some View {
        GeometryReader { proxy in
            let safeAreaPadding = (proxy.size.width - itemWidth - itemPadding) / 2
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    content
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
            .safeAreaPadding(.horizontal, safeAreaPadding)
        }
    }
}



#Preview {
    VStack {
        // 음악 플레이어 스타일
        let itemSize1: CGFloat = 180
        let itemPadding1: CGFloat = 50
        CarouselView(itemWidth: itemSize1, itemPadding: itemPadding1) {
            let colors: [Color] = [.red, .blue, .black, .yellow, .green]
            ForEach(colors, id: \.self) {
                Circle()
                    .fill($0)
                    .frame(width: itemSize1, height: itemSize1)
                    .padding(.horizontal, itemPadding1 / 2)

                    .scrollTransition(.interactive, axis: .horizontal) { view, phase in
                        view
                            .scaleEffect(phase.isIdentity ? 1 : 0.889)
                    }
            }
        }

        // 앨범 스타일
        let itemSize2: CGFloat = 280
        let itemPadding2: CGFloat = 24
        CarouselView(itemWidth: itemSize2, itemPadding: itemPadding2) {
            let colors: [Color] = [.red, .blue, .black, .yellow, .green]
            ForEach(colors, id: \.self) {
                Rectangle()
                    .fill($0)
                    .frame(width: itemSize2, height: itemSize2)
                    .padding(.horizontal, itemPadding2 / 2)

                    .scrollTransition(.interactive, axis: .horizontal) { view, phase in
                        view
                            .scaleEffect(phase.isIdentity ? 1 : 0.889)
                    }
            }
        }


    }
}
