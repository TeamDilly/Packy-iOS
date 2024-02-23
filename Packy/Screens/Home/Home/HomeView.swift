//
//  HomeView.swift
//  Packy
//
//  Created Mason Kim on 1/7/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct HomeView: View {
    @Bindable private var store: StoreOf<HomeFeature>
    @State private var easterEggShakeAnimation: Bool = false

    init(store: StoreOf<HomeFeature>) {
        self.store = store
    }

    enum ThrottleId: String {
        case moveToBoxDetail
    }

    var body: some View {
        VStack {
            navigationBar
                .padding(.top, 8)
            ScrollView {
                VStack(spacing: 16) {
                    NavigationLink(
                        state: MainTabNavigationPath.State.boxAddInfo()
                    ) {
                        topBanner
                    }
                    .buttonStyle(.bouncy)

                    if !store.giftBoxes.isEmpty {
                        giftBoxesListView
                    }

                    if !store.unsentBoxes.isEmpty {
                        unsentBoxesList
                    }
                }
                .safeAreaPadding(.bottom, 20)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .popGestureEnabled()
        .padding(.horizontal, 16)
        .background(.gray100)
        .task {
            await store
                .send(._onTask)
                .finish()
        }
        .showLoading(store.isShowDetailLoading)
    }
}

// MARK: - Inner Views

private extension HomeView {
    var navigationBar: some View {
        HStack {
            Image(.logo)
                .shake(isOn: $easterEggShakeAnimation)
                .onTapGesture(count: 5) {
                    easterEggShakeAnimation = true
                }
                .sensoryFeedback(.increase, trigger: easterEggShakeAnimation)

            Spacer()

            NavigationLink(state: MainTabNavigationPath.State.setting(.init())) {
                Image(.setting)
            }
            .frame(width: 40, height: 40)
        }
        .frame(height: 48)
    }

    var topBanner: some View {
        VStack(spacing: 0) {
            Text("패키의 특별한 선물박스로\n더 특별하게 마음을 나눠보아요")
                .packyFont(.heading3)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .padding(.top, 34)

            Image(.homeBanner)

            Text("선물박스 만들기")
                .packyFont(.body4)
                .foregroundStyle(.gray900)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.white)
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.black)
        )
    }

    var giftBoxesListView: some View {
        VStack(spacing: 24) {
            HStack {
                Text("주고받은 선물박스")
                    .packyFont(.heading2)
                    .foregroundStyle(.gray900)

                Spacer()


                Button("더보기") {
                    store.send(.viewMoreButtonTapped)
                }
                .buttonStyle(.text)
            }
            .padding(.horizontal, 24)


            ScrollView(.horizontal) {
                HStack(alignment: .top, spacing: 16) {
                    ForEach(store.giftBoxes, id: \.id) { giftBox in
                        BoxInfoCell(
                            boxUrl: giftBox.boxImageUrl,
                            senderReceiverInfo: giftBox.senderReceiverInfo,
                            boxTitle: giftBox.name
                        )
                        .bouncyTapGesture {
                            throttle(identifier: ThrottleId.moveToBoxDetail.rawValue) {
                                store.send(.tappedGiftBox(boxId: giftBox.id))
                            }
                        }
                    }
                }
            }
            .safeAreaPadding(.horizontal, 24)
            .scrollIndicators(.hidden)
        }
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.white)
        )
    }

    var unsentBoxesList: some View {
        LazyVStack(spacing: 24) {
            Text("보내지 않은 선물박스")
                .packyFont(.heading2)
                .foregroundStyle(.gray900)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(store.unsentBoxes, id: \.id) { unsentBox in
                UnsentBoxCell(
                    boxImageUrl: unsentBox.imageUrl,
                    receiver: unsentBox.receiverName,
                    title: unsentBox.name,
                    generatedDate: unsentBox.date,
                    menuAlignment: .center, 
                    menuAction: {
                        store.send(.binding(.set(\.selectedBoxToDelete, unsentBox)))
                    }
                )
                .bouncyTapGesture {
                    store.send(.tappedUnsentBox(boxId: unsentBox.id))
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.white)
        )
    }
}

private struct BoxInfoCell: View {
    var boxUrl: String
    var senderReceiverInfo: String
    var boxTitle: String

    var body: some View {
        VStack(spacing: 0) {
            NetworkImage(url: boxUrl)
                .mask(RoundedRectangle(cornerRadius: 8))
                .frame(height: 138)
                .padding(.bottom, 12)

            Text(senderReceiverInfo)
                .packyFont(.body6)
                .foregroundStyle(.purple500)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 4)

            Text(boxTitle)
                .packyFont(.body3)
                .foregroundStyle(.gray900)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(2)
        }
        .frame(width: 120)
    }
}

// MARK: - Preview

#Preview {
    HomeView(
        store: .init(
            initialState: .init(),
            reducer: {
                HomeFeature()
                    ._printChanges()
            }
        )
    )
}
