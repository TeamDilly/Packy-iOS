//
//  MyBoxFeature.swift
//  Packy
//
//  Created Mason Kim on 2/4/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct MyBoxFeature: Reducer {

    struct State: Equatable {
        @BindingState var selectedTab: MyBoxTab = .sentBox

        var receivedBoxesData: [SentReceivedGiftBoxPageData] = []
        var sentBoxesData: [SentReceivedGiftBoxPageData] = []

        var receivedBoxes: [SentReceivedGiftBox] {
            receivedBoxesData.flatMap(\.giftBoxes)
        }
        var sentBoxes: [SentReceivedGiftBox] {
            sentBoxesData.flatMap(\.giftBoxes)
        }

        var isLoading: Bool = true
    }

    enum Action: BindableAction {
        // MARK: User Action
        case binding(BindingAction<State>)
        case backButtonTapped

        // MARK: Inner Business Action
        case _onTask
        case _fetchMoreSentGiftBoxes
        case _fetchMoreReceivedGiftBoxes

        // MARK: Inner SetState Action
        case _setGiftBoxData(SentReceivedGiftBoxPageData, GiftBoxType)
        case _setLoading(Bool)

        // MARK: Child Action
        enum Delegate {
            case tappedGifBox(boxId: Int)
        }
        case delegate(Delegate)
    }

    @Dependency(\.boxClient) var boxClient
    @Dependency(\.dismiss) var dismiss

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce<State, Action> { state, action in
            switch action {
            case .binding:
                return .none

            case .backButtonTapped:
                return .run { _ in await dismiss() }

            case ._fetchMoreSentGiftBoxes:
                let lastBoxDate = state.sentBoxes.last?.giftBoxDate ?? .init()
                return fetchGiftBoxes(type: .sent, lastBoxDate: lastBoxDate)

            case ._fetchMoreReceivedGiftBoxes:
                let lastBoxDate = state.receivedBoxes.last?.giftBoxDate ?? .init()
                return fetchGiftBoxes(type: .received, lastBoxDate: lastBoxDate)

            case let ._setGiftBoxData(giftBoxData, type):
                switch type {
                case .received:
                    state.receivedBoxesData.append(giftBoxData)
                case .sent:
                    state.sentBoxesData.append(giftBoxData)
                default: break
                }
                return .none

            case let ._setLoading(isLoading):
                state.isLoading = isLoading
                return .none

            case ._onTask:
                return .merge(
                    fetchGiftBoxes(type: .received, lastBoxDate: nil),
                    fetchGiftBoxes(type: .sent, lastBoxDate: nil)
                )

            case .delegate:
                return .none
            }
        }
    }
}

private extension MyBoxFeature {
    func fetchGiftBoxes(type: GiftBoxType, lastBoxDate: Date?) -> Effect<Action> {
        .run { send in
            do {
                let giftBoxesData = try await boxClient.fetchGiftBoxes(
                    .init(
                        lastGiftBoxDate: lastBoxDate?.formattedString(by: .yyyyMMddTHHmmssServerDateTime),
                        type: type
                    )
                )
                await send(._setGiftBoxData(giftBoxesData, type), animation: .spring)
                await send(._setLoading(false), animation: .spring)
            } catch {
                print("🐛 \(error)")
            }
        }
    }
}
