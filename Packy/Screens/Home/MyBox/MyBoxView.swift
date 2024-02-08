//
//  MyBoxView.swift
//  Packy
//
//  Created Mason Kim on 2/4/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct MyBoxView: View {
    private let store: StoreOf<MyBoxFeature>
    @ObservedObject private var viewStore: ViewStoreOf<MyBoxFeature>

    init(store: StoreOf<MyBoxFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    enum ThrottleId: String {
        case moveToBoxDetail
    }

    var body: some View {
        VStack(spacing: 0) {
            NavigationBar.onlyBackButton {
                viewStore.send(.backButtonTapped)
            }
            .padding(.top, 8)

            TabSegmentedControl(
                selectedTab: viewStore.$selectedTab,
                selections: MyBoxTab.allCases
            )
            .padding(.top, 26)

            boxGridTabView
                .animation(.spring, value: viewStore.selectedTab)
                .background(.gray100)
                .safeAreaPadding(.bottom, 30)

            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea(edges: .bottom)
        .task {
            await viewStore
                .send(._onTask)
                .finish()
        }
    }
}

// MARK: - Inner Views

private extension MyBoxView {
    var boxGridTabView: some View {
        TabView(selection: viewStore.$selectedTab) {
            boxGridView(.sentBox)
                .tag(MyBoxTab.sentBox)

            boxGridView(.receivedBox)
                .tag(MyBoxTab.receivedBox)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .ignoresSafeArea(edges: .bottom)
    }

    @ViewBuilder
    func boxGridView(_ tab: MyBoxTab) -> some View {
        let columns = [GridItem(spacing: 16), GridItem(spacing: 16)]
        let giftBoxes = giftBoxes(for: tab)

        if !viewStore.isLoading && giftBoxes.isEmpty {
            switch tab {
            case .sentBox:
                emptySentStateView
            case .receivedBox:
                EmptyView()  // TODO: 변경 필요
            }
        } else {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(giftBoxes, id: \.id) { giftBox in
                        MyBoxInfoCell(
                            tabInfo: tab,
                            boxUrl: giftBox.boxImageUrl,
                            senderReceiverInfo: giftBox.senderReceiverInfo,
                            boxTitle: giftBox.name,
                            date: giftBox.giftBoxDate
                        )
                        .bouncyTapGesture {
                            throttle(identifier: ThrottleId.moveToBoxDetail.rawValue) {
                                HapticManager.shared.fireFeedback(.soft)
                                viewStore.send(.delegate(.tappedGifBox(boxId: giftBox.id)))
                            }
                        }


                        if latestPageData(for: tab)?.isLastPage == false {
                            PackyProgress()
                                .onAppear {
                                    switch tab {
                                    case .sentBox:
                                        viewStore.send(._fetchMoreSentGiftBoxes)
                                    case .receivedBox:
                                        viewStore.send(._fetchMoreReceivedGiftBoxes)
                                    }
                                }
                        }

                    }
                }
                .padding(24)
            }
            .scrollIndicators(.hidden)
        }
    }

    var emptySentStateView: some View {
        VStack(spacing: 0) {
            Text("아직 보낸 선물박스가 없어요")
                .packyFont(.heading2)
                .foregroundStyle(.gray900)
                .padding(.bottom, 4)

            Text("패키의 선물박스로 마음을 나눠보아요")
                .packyFont(.body4)
                .foregroundStyle(.gray900)
                .padding(.bottom, 24)

            Button("선물박스 만들기") {

            }
            .buttonStyle(.box(color: .primary, size: .roundMedium, trailingImage: .arrowRight))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

private struct MyBoxInfoCell: View {
    var tabInfo: MyBoxTab
    var boxUrl: String
    var senderReceiverInfo: String
    var boxTitle: String
    var date: Date

    var body: some View {
        VStack(spacing: 0) {
            NetworkImage(url: boxUrl)
                .mask(RoundedRectangle(cornerRadius: 8))
                .frame(height: 138)
                .padding(.bottom, 12)

            VStack(spacing: 4) {
                Text(senderReceiverInfo)
                    .packyFont(.body6)
                    .foregroundStyle(.purple500)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(boxTitle)
                    .packyFont(.body3)
                    .foregroundStyle(.gray900)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(2)
                    .frame(height: 44, alignment: .top)

                Text(date.formattedString(by: .yyyyMdKorean))
                    .packyFont(.body6)
                    .foregroundStyle(.gray600)
                    .frame(maxWidth: .infinity, alignment: .leading)

            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
        )
    }
}

// MARK: - Inner Functions

private extension MyBoxView {
    func giftBoxes(for tab: MyBoxTab) -> [SentReceivedGiftBox] {
        switch tab {
        case .sentBox:      return viewStore.sentBoxes
        case .receivedBox:  return viewStore.receivedBoxes
        }
    }

    func latestPageData(for tab: MyBoxTab) -> SentReceivedGiftBoxPageData? {
        switch tab {
        case .sentBox:      return viewStore.sentBoxesData.last
        case .receivedBox:  return viewStore.receivedBoxesData.last
        }
    }
}

// MARK: - Preview

#Preview {
    MyBoxView(
        store: .init(
            initialState: .init(),
            reducer: {
                MyBoxFeature()
                    ._printChanges()
            }
        )
    )
}
