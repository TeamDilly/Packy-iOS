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
    @Environment(\.scenePhase) private var scenePhase

    init(store: StoreOf<GiftArchiveFeature>) {
        self.store = store
    }

    var body: some View {
        VStack {
            if store.gifts.isEmpty && !store.isLoading {
                Text("아직 받은 선물이 없어요")
                    .packyFont(.body2)
                    .foregroundStyle(.gray600)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.bottom, 50)
            } else {
                StaggeredGrid(columns: 2, data: store.gifts.elements) { gift in
                    GiftCell(imageUrl: gift.gift.url)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            HapticManager.shared.fireFeedback(.soft)
                            store.send(.giftTapped(gift))
                        }
                        .onAppear {
                            // Pagination
                            guard store.isLastPage == false,
                                  let index = store.gifts.firstIndex(of: gift) else { return }

                            let isNearEndForNextPageLoad = index == store.gifts.endIndex - 3
                            guard isNearEndForNextPageLoad else { return }
                            store.send(._fetchMoreGifts)
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
            await store
                .send(.didRefresh)
                .finish()
        }
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
