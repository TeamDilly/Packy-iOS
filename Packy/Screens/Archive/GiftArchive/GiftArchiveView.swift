//
//  GiftArchiveView.swift
//  Packy
//
//  Created Mason Kim on 2/18/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct GiftArchiveView: View {
    private let store: StoreOf<GiftArchiveFeature>
    @ObservedObject private var viewStore: ViewStoreOf<GiftArchiveFeature>
    @Environment(\.scenePhase) private var scenePhase

    init(store: StoreOf<GiftArchiveFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        VStack {
            if viewStore.gifts.isEmpty && !viewStore.isLoading {
                Text("아직 받은 선물이 없어요")
                    .packyFont(.body2)
                    .foregroundStyle(.gray600)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.bottom, 50)
            } else {
                StaggeredGrid(columns: 2, data: viewStore.gifts.elements) { gift in
                    GiftCell(imageUrl: gift.gift.url)
                        .bouncyTapGesture {
                            viewStore.send(.giftTapped(gift))
                        }
                        .onAppear {
                            // Pagination
                            guard viewStore.isLastPage == false,
                                  let index = viewStore.gifts.firstIndex(of: gift) else { return }

                            let isNearEndForNextPageLoad = index == viewStore.gifts.endIndex - 3
                            guard isNearEndForNextPageLoad else { return }
                            viewStore.send(._fetchMoreGifts)
                        }
                }
                .zigzagPadding(80)
                .innerSpacing(vertical: 16, horizontal: 16)
                .transition(.opacity)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 24)
        .background(.gray100)
        .refreshable {
            await viewStore.send(.didRefresh, while: \.isLoading)
        }
        .didLoad {
            await viewStore
                .send(._onTask)
                .finish()
        }
        .onChange(of: scenePhase) {
            guard $1 == .active else { return }
            viewStore.send(._didActiveScene)
        }
    }
}

// MARK: - Inner Views

private struct GiftCell: View {
    var imageUrl: String

    var body: some View {
        NetworkImage(url: imageUrl, contentMode: .fill, cropAlignment: .top)
            .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - Preview

#Preview {
    GiftArchiveView(
        store: .init(
            initialState: .init(),
            reducer: {
                GiftArchiveFeature()
                    ._printChanges()
            }
        )
    )
}
