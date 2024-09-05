//
//  BannersCarousel.swift
//  Packy
//
//  Created by Mason Kim on 8/31/24.
//

import SwiftUI
import Combine

struct BannersCarousel<Item, Content: View>: View {
    private let items: [Item]
    @State private var indexedItems: [IndexedItem<Item>] = []
    private let contentBuilder: (Item) -> Content

    init(
        items: [Item],
        @ViewBuilder contentBuilder: @escaping (Item) -> Content
    ) {
        self.items = items
        self.contentBuilder = contentBuilder
    }

    @State private var centeredItemID: IndexedItem<Item>.ID?
    @State private var timer = Timer.publish(every: 3, on: .main, in: .common)
    @State private var connectedTimer: Cancellable?

    private var onTapAction: ((Item) -> Void)?

    var currentIndex: Int {
        guard let centeredItemID else { return 0 }
        return centeredItemID % items.count
    }
    var centeredItem: Item? {
        items[safe: currentIndex] ?? items.first
    }

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(indexedItems) { item in
                    contentBuilder(item.element)
                        .containerRelativeFrame(.horizontal)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollIndicators(.hidden)
        .scrollPosition(id: $centeredItemID)
        .aspectRatio(358 / 76, contentMode: .fit)
        .clipShape(
            RoundedRectangle(cornerRadius: 24)
        )
        .overlay(alignment: .bottomTrailing) {
            currentIndexOverlayView
                .padding(12)
        }
        .padding(.horizontal, 16)
        .onAppear {
            indexedItems = items.indexedItems(repeatCount: 100)
            self.centeredItemID = indexedItems.count / 2

            instantiateTimer()
        }
        .onDisappear {
            cancelTimer()
        }
        .onChange(of: centeredItemID) { _, _ in
            // 스크롤할 때 타이머 리셋
            restartTimer()
        }
        .onReceive(timer) { _ in
            moveToNextBannerIndex()
        }
        .ifLet(onTapAction) { view, action in
            view
                .bouncyTapGesture {
                    guard let centeredItem else { return }
                    action(centeredItem)
                } onPressing: { isPressing in
                    if isPressing {
                        cancelTimer()
                    } else {
                        instantiateTimer()
                    }
                }
        }
    }
}

// MARK: - Inner Views

private extension BannersCarousel {
    @ViewBuilder
    var currentIndexOverlayView: some View {
        if items.count > 1 {
            HStack(spacing: 1) {
                Group {
                    Text("\(currentIndex + 1)")
                    Text("/")
                    Text("\(items.count)")
                }
                .foregroundStyle(.white)
                .packyFont(.body6)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 1)
            .background(.black.opacity(0.6))
            .clipShape(Capsule())
        }
    }
}

// MARK: - Inner Functions

private extension BannersCarousel {
    func moveToNextBannerIndex() {
        withAnimation {
            centeredItemID = ((centeredItemID ?? 0) + 1) % indexedItems.count
        }
    }

    func instantiateTimer() {
        timer = Timer.publish(every: 3, on: .main, in: .common)
        connectedTimer = timer.connect()
    }

    func cancelTimer() {
        connectedTimer?.cancel()
    }

    func restartTimer() {
        cancelTimer()
        instantiateTimer()
    }
}

// MARK: - View Modifiers

extension BannersCarousel {
    func onTapAction(_ onTapAction: @escaping (Item) -> Void) -> Self {
        var carousel = self
        carousel.onTapAction = onTapAction
        return carousel
    }
}

// MARK: - Preview

#Preview {
    struct SampleItem {
        var title: String
        var color: Color
    }

    return BannersCarousel(items: [
        SampleItem(title: "red", color: .red),
        SampleItem(title: "blue", color: .blue),
        SampleItem(title: "purple", color: .purple),
        SampleItem(title: "gray", color: .gray)
    ]) { item in
        Text("\(item.title)")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(item.color.gradient)
    }
    .onTapAction { item in
        print(item.title)
    }
}
