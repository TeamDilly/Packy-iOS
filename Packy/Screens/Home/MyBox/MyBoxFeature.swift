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

        var isFetchBoxesLoading: Bool = true
        var isShowDetailLoading: Bool = false
    }

    enum Action: BindableAction {
        // MARK: User Action
        case binding(BindingAction<State>)
        case backButtonTapped
        case tappedGiftBox(boxId: Int)

        // MARK: Inner Business Action
        case _onTask
        case _fetchMoreSentGiftBoxes
        case _fetchMoreReceivedGiftBoxes

        // MARK: Inner SetState Action
        case _setGiftBoxData(SentReceivedGiftBoxPageData, GiftBoxType)
        case _setFetchBoxLoading(Bool)
        case _setShowDetailLoading(Bool)

        // MARK: - Delegate Action
        enum Delegate {
            case moveToBoxDetail(ReceivedGiftBox)
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

            case let .tappedGiftBox(boxId):
                state.isShowDetailLoading = true
                return .run { send in
                    do {
                        let giftBox = try await boxClient.openGiftBox(boxId)
                        await send(.delegate(.moveToBoxDetail(giftBox)))
                        await send(._setShowDetailLoading(false))
                    } catch {
                        print("🐛 \(error)")
                    }
                }

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

            case let ._setFetchBoxLoading(isLoading):
                state.isFetchBoxesLoading = isLoading
                return .none

            case let ._setShowDetailLoading(isLoading):
                state.isShowDetailLoading = isLoading
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
                await send(._setFetchBoxLoading(false), animation: .spring)
            } catch {
                print("🐛 \(error)")
            }
        }
    }
}
