//
//  CarouselView.swift
//  Packy
//
//  Created by Mason Kim on 1/12/24.
//

import SwiftUI


struct CarouselView<Content: View, Item: Identifiable & Hashable>: View {
    private let itemWidth: CGFloat
    private let itemPadding: CGFloat
    private let contentBuilder: (Item) -> Content
    private let items: [Item]
    private var minifyScale: CGFloat = 1 // 좌우의 효과에 의해 작아진 아이템의 scale

    private var centeredItem: Binding<Item?>?
    private var isCollapsing: Bool = true

    init(
        items: [Item],
        itemWidth: CGFloat? = nil,
        itemPadding: CGFloat = 0,
        @ViewBuilder contentBuilder: @escaping (Item) -> Content
    ) {
        self.items = items
        self.itemWidth = itemWidth ?? 0
        self.itemPadding = itemPadding
        self.contentBuilder = contentBuilder
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(items) { item in
                        contentBuilder(item)
                            .id(item)
                            .frame(width: isCollapsing ? itemWidth : nil)
                            .containerRelativeFrame(.horizontal)
                            .scrollTransition(.interactive, axis: .horizontal) { view, phase in
                                view
                                    .scaleEffect(phase.isIdentity ? 1 : minifyScale)
                            }
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
            .safeAreaPadding(.horizontal, isCollapsing ? safeAreaPadding(geometryWidth: geometry.size.width) : 0)
            .scrollPosition(id: centeredItem ?? .constant(items.first))
        }
    }


    private func safeAreaPadding(geometryWidth: CGFloat) -> CGFloat {
        (geometryWidth - itemWidth - itemPadding) / 2 + generatedPaddingByMinifyScale / 2
    }

    /// 좌우 아이템 작게 만드는 효과에 의해 생성된 패딩값
    private var generatedPaddingByMinifyScale: CGFloat {
        // 원래 width 500 -> 0.8 배율 -> 작아진 width 400 ...
        // 차이값 100 / 2 인 50 만큼 padding 생김. -> 해당 값만큼 HStack padding 에 빼주면 됨
        let sizeDifference = (1 - minifyScale) * itemWidth
        return sizeDifference / 2
    }
}

extension CarouselView {
    /// 스크롤을 할 때, 좌우의 아이템이 작아지는 효과를 부여
    func minifyScale(_ minifyScale: CGFloat) -> Self {
        var carousel = self
        carousel.minifyScale = minifyScale
        return carousel
    }

    func centeredItem(_ centeredItem: Binding<Item?>) -> Self {
        var carousel = self
        carousel.centeredItem = centeredItem
        return carousel
    }

    func disableCollapsing() -> Self {
        var carousel = self
        carousel.isCollapsing = false
        return carousel
    }
}

extension Color: Identifiable {
    public var id: String { self.description }
}

#Preview {
    struct SampleView: View {
        @State private var selectedColor: Color? = .red

        var body: some View {
            VStack {
                let colors: [Color] = [.red, .blue, .black, .yellow, .green]

                // 음악 플레이어 스타일
                let itemSize1: CGFloat = 180
                let itemPadding1: CGFloat = 50
                CarouselView(items: colors, itemWidth: itemSize1, itemPadding: itemPadding1) {
                    Circle()
                        .fill($0)
                }
                .minifyScale(0.5)
                .centeredItem($selectedColor)
                .border(Color.black)

                CarouselView(items: colors) {
                    Circle()
                        .fill($0)
                        .frame(width: 200, height: 200)
                }
                .centeredItem($selectedColor)
                .disableCollapsing()
                .border(Color.black)

                // 앨범 스타일
                let itemSize2: CGFloat = 280
                let itemPadding2: CGFloat = 24
                CarouselView(items: colors, itemWidth: itemSize2, itemPadding: itemPadding2) {
                    Rectangle()
                        .fill($0)
                }
                .minifyScale(0.5)
            }
            .onChange(of: selectedColor) {
                print($0, $1)
            }
        }
    }

    return SampleView()
}
