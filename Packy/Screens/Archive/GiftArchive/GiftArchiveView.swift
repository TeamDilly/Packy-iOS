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
            StaggeredGrid(columns: 2, data: viewStore.gifts.elements) { gift in
                GiftCell(imageUrl: gift.gift.url)
                    .onTapGesture {
                        HapticManager.shared.fireFeedback(.soft)
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
        .padding(.horizontal, 24)
        .background(.gray100)
        .refreshable {
            viewStore.send(.didRefresh)
        }
        .didLoad {
            await viewStore
                .send(._onTask)
                .finish()
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
