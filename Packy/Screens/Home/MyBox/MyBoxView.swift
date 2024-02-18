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
            navigationBar
                .padding(.top, 16)

            TabSegmentedControl(
                selectedTab: viewStore.$selectedTab,
                selections: MyBoxTab.allCases
            )
            .padding(.top, 32)

            boxGridTabView
                .animation(.spring, value: viewStore.selectedTab)
                .background(.gray100)
                .safeAreaPadding(.bottom, 30)

            Spacer()
        }
        // FIXME: 변경
        // .bottomMenu(
        //     isPresented: .init(
        //         get: { viewStore.selectedBoxToDelete != nil },
        //         set: {
        //             guard $0 == false else { return }
        //             viewStore.send(.binding(.set(\.$selectedBoxToDelete, nil)))
        //         }
        //     ),
        //     confirmTitle: "삭제하기",
        //     confirmAction: {
        //         viewStore.send(.deleteBottomMenuConfirmButtonTapped)
        //     }
        // )
        .showLoading(viewStore.isShowDetailLoading)
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
    var navigationBar: some View {
        Text("선물박스")
            .packyFont(.heading1)
            .foregroundStyle(.gray900)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 24)
    }

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

        if viewStore.isFetchBoxesLoading {
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
                                viewStore.send(.binding(.set(\.$selectedBoxToDelete, giftBox)))
                            }
                        )
                        .bouncyTapGesture {
                            throttle(identifier: ThrottleId.moveToBoxDetail.rawValue) {
                                viewStore.send(.tappedGiftBox(boxId: giftBox.id))
                            }
                        }
                        .simultaneousGesture(
                            LongPressGesture()
                                .onEnded { _ in
                                    viewStore.send(.binding(.set(\.$selectedBoxToDelete, giftBox)))
                                }
                        )
                    }
                }
                .padding(24)

                if isLastPage(for: tab) == false {
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
        case .sentBox:      return viewStore.sentBoxes
        case .receivedBox:  return viewStore.receivedBoxes
        }
    }

    func isLastPage(for tab: MyBoxTab) -> Bool {
        switch tab {
        case .sentBox:      return viewStore.sentBoxesData?.isLastPage ?? true
        case .receivedBox:  return viewStore.receivedBoxesData?.isLastPage ?? true
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
