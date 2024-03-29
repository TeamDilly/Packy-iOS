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
    @Bindable private var store: StoreOf<MyBoxFeature>
    @Environment(\.scenePhase) private var scenePhase

    init(store: StoreOf<MyBoxFeature>) {
        self.store = store
    }

    enum ThrottleId: String {
        case moveToBoxDetail
    }

    var body: some View {
        VStack(spacing: 0) {
            navigationBar
                .padding(.top, 16)
                .padding(.bottom, 32)

            if !store.unsentBoxes.isEmpty {
                unsentBoxesCarousel
                    .padding(.bottom, 12)
            }

            TabSegmentedControl(
                selectedTab: $store.selectedTab,
                selections: MyBoxTab.allCases
            )

            boxGridTabView
                .animation(.spring, value: store.selectedTab)
                .background(.gray100)
                .safeAreaPadding(.bottom, 30)
                .frame(maxHeight: .infinity)
        }
        .showLoading(store.isShowDetailLoading)
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea(edges: .bottom)
        .task {
            await store
                .send(._onTask)
                .finish()
        }
        .onChange(of: scenePhase) {
            guard $1 == .active else { return }
            store.send(._didActiveScene)
        }
    }
}

// MARK: - Inner Views

private extension MyBoxView {
    var navigationBar: some View {
        Text("선물박스")
            .packyFont(.heading1)
            .foregroundStyle(.gray900)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 24)
    }

    @ViewBuilder
    var unsentBoxesCarousel: some View {
        VStack(spacing: 0) {
            Text("보내지 않은 선물박스")
                .packyFont(.body1)
                .foregroundStyle(.gray900)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.bottom, 12)

            ScrollView(.horizontal) {
                HStack(spacing: 16) {
                    ForEach(store.unsentBoxes) { unsentBox in
                        UnsentBoxCell(
                            boxImageUrl: unsentBox.imageUrl,
                            receiver: unsentBox.receiverName,
                            title: unsentBox.name,
                            generatedDate: unsentBox.date,
                            menuAction: {
                                store.send(.binding(.set(\.selectedBoxIdToDelete, unsentBox.id)))
                            }
                        )
                        .bouncyTapGesture {
                            store.send(.tappedGiftBox(boxId: unsentBox.id, isUnsent: true))
                        }
                        .padding(16)
                        .background(.gray100)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .containerRelativeFrame(.horizontal)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
            .safeAreaPadding(.leading, 24)
            .safeAreaPadding(.trailing, 40)
        }
    }

    var boxGridTabView: some View {
        TabView(selection: $store.selectedTab) {
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

        if store.isFetchBoxesLoading {
            PackyProgress()
        } else if giftBoxes.isEmpty {
            switch tab {
            case .sentBox:
                emptySentStateView
            case .receivedBox:
                emptyReceivedStateView
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
                            date: giftBox.giftBoxDate,
                            menuAction: {
                                store.send(.binding(.set(\.selectedBoxIdToDelete, giftBox.id)))
                            }
                        )
                        .bouncyTapGesture {
                            throttle(identifier: ThrottleId.moveToBoxDetail.rawValue) {
                                store.send(.tappedGiftBox(boxId: giftBox.id, isUnsent: false))
                            }
                        }
                        .onAppear {
                            // Pagination
                            guard isLastPage(for: tab) == false,
                                  let giftBoxIndex = giftBoxes.firstIndex(of: giftBox) else { return }

                            let isNearEndForNextPageLoad = giftBoxIndex == giftBoxes.endIndex - 3
                            guard isNearEndForNextPageLoad else { return }

                            switch tab {
                            case .sentBox:
                                store.send(._fetchMoreSentGiftBoxes)
                            case .receivedBox:
                                store.send(._fetchMoreReceivedGiftBoxes)
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

            NavigationLink(
                "선물박스 만들기",
                state: MainTabNavigationPath.State.boxAddInfo()
            )
            .buttonStyle(.box(color: .primary, size: .roundMedium, trailingImage: .arrowRight))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    var emptyReceivedStateView: some View {
        VStack(spacing: 0) {
            Text("아직 받은 선물박스가 없어요")
                .packyFont(.heading2)
                .foregroundStyle(.gray900)
                .padding(.bottom, 4)

            Text("패키의 선물박스로 마음을 나눠보아요")
                .packyFont(.body4)
                .foregroundStyle(.gray900)
                .padding(.bottom, 24)
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
    var menuAction: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            NetworkImage(url: boxUrl)
                .mask(RoundedRectangle(cornerRadius: 8))
                .aspectRatio(131 / 150, contentMode: .fit)
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

                HStack {
                    Text(date.formattedString(by: .yyyyMdKorean))
                        .packyFont(.body6)
                        .foregroundStyle(.gray600)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Button {
                        menuAction()
                    } label: {
                        Image(.ellipsis)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.gray600)
                    }
                }
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
        case .sentBox:      return store.sentBoxes.elements
        case .receivedBox:  return store.receivedBoxes.elements
        }
    }

    func isLastPage(for tab: MyBoxTab) -> Bool {
        switch tab {
        case .sentBox:      return store.isSentBoxesLastPage
        case .receivedBox:  return store.isReceivedBoxesLastPage
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
    .packyGlobalAlert()
}
