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
    }

    enum Action {
        // MARK: User Action

        // MARK: Inner Business Action
        case _onTask
        case _didActiveScene
        case _fetchMoreGifts

        // MARK: Inner SetState Action
        case _setGiftPageData(GiftArchivePageData)
    }

    @Dependency(\.archiveClient) var archiveClient

    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case ._onTask:
                guard state.giftArchivePageData.isEmpty else { return .none }
                return fetchGifts(lastGiftId: nil)

            case ._didActiveScene:
                state.giftArchivePageData = []
                state.gifts = []
                return fetchGifts(lastGiftId: nil)

            case let ._setGiftPageData(pageData):
                state.giftArchivePageData.append(pageData)
                state.gifts.append(contentsOf: pageData.content)
                return .none

            case ._fetchMoreGifts:
                return fetchGifts(lastGiftId: state.gifts.last?.id)
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
            } catch {
                print("🐛 \(error)")
            }
        }
    }
}
