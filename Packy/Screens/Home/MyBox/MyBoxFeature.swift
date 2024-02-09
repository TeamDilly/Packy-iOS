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

        var receivedBoxesData: SentReceivedGiftBoxPageData?
        var sentBoxesData: SentReceivedGiftBoxPageData?

        var receivedBoxes: [SentReceivedGiftBox] {
            receivedBoxesData?.giftBoxes.sorted(by: \.giftBoxDate) ?? []
        }
        var sentBoxes: [SentReceivedGiftBox] {
            sentBoxesData?.giftBoxes.sorted(by: \.giftBoxDate) ?? []
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
                return fetchGiftBoxes(type: .sent, currentSize: state.sentBoxes.count)

            case ._fetchMoreReceivedGiftBoxes:
                return fetchGiftBoxes(type: .received, currentSize: state.receivedBoxes.count)

            case let ._setGiftBoxData(giftBoxData, type):
                switch type {
                case .received:
                    state.receivedBoxesData = giftBoxData
                case .sent:
                    state.sentBoxesData = giftBoxData
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
                    fetchGiftBoxes(type: .received, currentSize: 0),
                    fetchGiftBoxes(type: .sent, currentSize: 0)
                )

            case .delegate:
                return .none
            }
        }
    }
}

private extension MyBoxFeature {
    // TODO: 페이지네이션 관련 로직 확인 필요 _ 배열로 관리해서 더하는 형태인지? 일단은 size를 늘리는 형태로 처리하도록 함
    func fetchGiftBoxes(type: GiftBoxType, currentSize: Int) -> Effect<Action> {
        .run { send in
            do {
                let giftBoxesData = try await boxClient.fetchGiftBoxes(
                    .init(
                        type: type,
                        size: currentSize + 6
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
