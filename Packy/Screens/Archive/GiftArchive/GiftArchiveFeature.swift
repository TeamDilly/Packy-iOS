//
//  GiftArchiveFeature.swift
//  Packy
//
//  Created Mason Kim on 2/18/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct GiftArchiveFeature: Reducer {

    struct State: Equatable {
        fileprivate var giftArchivePageData: [GiftArchivePageData] = []
        var isLastPage: Bool {
            giftArchivePageData.last?.last ?? true
        }

        var gifts: IdentifiedArrayOf<GiftArchiveData> = []
        @BindingState var selectedGift: GiftArchiveData?

        var isLoading: Bool = true
    }

    enum Action {
        // MARK: User Action
        case giftTapped(GiftArchiveData)
        case didRefresh

        // MARK: Inner Business Action
        case _onTask
        case _fetchMoreGifts
        case _didActiveScene

        // MARK: Inner SetState Action
        case _setGiftPageData(GiftArchivePageData)
        case _setLoading(Bool)
    }

    @Dependency(\.archiveClient) var archiveClient
    @Dependency(\.continuousClock) var clock

    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case let .giftTapped(gift):
                state.selectedGift = gift
                return .none
                
            case ._onTask:
                guard state.giftArchivePageData.isEmpty else { return .none }
                return fetchGifts(lastGiftId: nil)

            case .didRefresh, ._didActiveScene:
                state.giftArchivePageData = []
                state.gifts = []
                state.isLoading = true
                return fetchGifts(lastGiftId: nil)

            case let ._setGiftPageData(pageData):
                state.giftArchivePageData.append(pageData)
                state.gifts.append(contentsOf: pageData.content)
                return .none

            case ._fetchMoreGifts:
                return fetchGifts(lastGiftId: state.gifts.last?.id)

            case let ._setLoading(isLoading):
                state.isLoading = isLoading
                return .none
            }
        }
    }
}

private extension GiftArchiveFeature {
    func fetchGifts(lastGiftId: Int?) -> Effect<Action> {
        .run { send in
            do {
                let response = try await archiveClient.fetchGifts(lastGiftId)
                await send(._setGiftPageData(response), animation: .spring)

                try? await clock.sleep(for: .seconds(0.3))
                await send(._setLoading(false))
            } catch {
                print("🐛 \(error)")
                await send(._setLoading(false))
            }
        }
    }
}
