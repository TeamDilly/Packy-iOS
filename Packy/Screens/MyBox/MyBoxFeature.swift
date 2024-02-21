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

        fileprivate var receivedBoxesData: [SentReceivedGiftBoxPageData] = []
        fileprivate var sentBoxesData: [SentReceivedGiftBoxPageData] = []

        var isReceivedBoxesLastPage: Bool { receivedBoxesData.last?.isLastPage ?? true }
        var isSentBoxesLastPage: Bool { sentBoxesData.last?.isLastPage ?? true }

        var receivedBoxes: IdentifiedArrayOf<SentReceivedGiftBox> = []
        var sentBoxes: IdentifiedArrayOf<SentReceivedGiftBox> = []
        var unsentBoxes: IdentifiedArrayOf<UnsentBox> = []

        @BindingState var selectedBoxIdToDelete: Int?

        var isFetchBoxesLoading: Bool = true
        var isShowDetailLoading: Bool = false
    }

    enum Action: BindableAction {
        // MARK: User Action
        case binding(BindingAction<State>)
        case tappedGiftBox(boxId: Int, isUnsent: Bool)
        case deleteBottomMenuConfirmButtonTapped

        // MARK: Inner Business Action
        case _onTask
        case _didActiveScene
        case _fetchMoreSentGiftBoxes
        case _fetchMoreReceivedGiftBoxes
        case _resetAndFetchGiftBoxes
        case _deleteBox(Int)

        // MARK: Inner SetState Action
        case _setGiftBoxData(SentReceivedGiftBoxPageData, GiftBoxType)
        case _setFetchBoxLoading(Bool)
        case _setShowDetailLoading(Bool)
        case _setDeletedBox(Int)
        case _setUnsentBoxes([UnsentBox])

        // MARK: Delegate Action
        enum Delegate {
            case moveToBoxDetail(boxId: Int, ReceivedGiftBox, isToSend: Bool)
        }
        case delegate(Delegate)
    }

    @Dependency(\.boxClient) var boxClient
    @Dependency(\.bottomMenu) var bottomMenu
    @Dependency(\.packyAlert) var packyAlert

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce<State, Action> { state, action in
            switch action {
            case ._onTask:
                return .merge(
                    fetchAllInitialGiftBoxes(state),
                    fetchUnsentBoxes()
                )

            case ._didActiveScene:
                return .send(._resetAndFetchGiftBoxes)

            case .binding(\.$selectedBoxIdToDelete):
                return .run { send in
                    await bottomMenu.show(
                        .init(
                            confirmTitle: "삭제하기",
                            confirmAction: {
                                await send(.deleteBottomMenuConfirmButtonTapped)
                            }
                        )
                    )
                }

            case .binding:
                return .none
                
            case let .tappedGiftBox(boxId, isUnsent):
                state.isShowDetailLoading = true
                return .run { send in
                    do {
                        let giftBox = try await boxClient.openGiftBox(boxId)
                        await send(.delegate(.moveToBoxDetail(boxId: boxId, giftBox, isToSend: isUnsent)))
                        await send(._setShowDetailLoading(false))
                    } catch {
                        print("🐛 \(error)")
                        await send(._setShowDetailLoading(false))
                    }
                }

            case .deleteBottomMenuConfirmButtonTapped:
                guard let selectedBoxIdToDelete = state.selectedBoxIdToDelete else { return .none }
                return .run { send in
                    await packyAlert.show(
                        .init(
                            title: "선물박스를 삭제할까요?",
                            description: "선물박스를 삭제하면 다시 볼 수 없어요\n선물박스에 담긴 선물들도 사라져요",
                            cancel: "취소",
                            confirm: "삭제",
                            confirmAction: {
                                await send(._deleteBox(selectedBoxIdToDelete))
                            }
                        )
                    )
                }

            case let ._deleteBox(boxId):
                return .run { send in
                    do {
                        try await boxClient.deleteGiftBox(boxId)
                        await send(._setDeletedBox(boxId))
                    } catch {
                        print("🐛 \(error)")
                    }
                }

            case ._fetchMoreSentGiftBoxes:
                guard let lastBoxData = state.sentBoxesData.last,
                      lastBoxData.isLastPage == false,
                      let lastBoxDate = lastBoxData.giftBoxes.last?.giftBoxDate else { return .none }

                return fetchGiftBoxes(
                    type: .sent,
                    lastGiftBoxDate: lastBoxDate
                )

            case ._fetchMoreReceivedGiftBoxes:
                guard let lastBoxData = state.receivedBoxesData.last,
                      lastBoxData.isLastPage == false,
                      let lastBoxDate = lastBoxData.giftBoxes.last?.giftBoxDate else { return .none }

                return fetchGiftBoxes(
                    type: .received,
                    lastGiftBoxDate: lastBoxDate
                )

            case ._resetAndFetchGiftBoxes:
                state.isFetchBoxesLoading = true
                state.sentBoxesData.removeAll()
                state.receivedBoxesData.removeAll()
                state.sentBoxes.removeAll()
                state.receivedBoxes.removeAll()
                return fetchAllInitialGiftBoxes(state)

            case let ._setGiftBoxData(giftBoxData, type):
                switch type {
                case .received:
                    state.receivedBoxesData.append(giftBoxData)
                    state.receivedBoxes.append(contentsOf: giftBoxData.giftBoxes)
                case .sent:
                    state.sentBoxesData.append(giftBoxData)
                    state.sentBoxes.append(contentsOf: giftBoxData.giftBoxes)
                default:
                    break
                }
                return .none

            case let ._setUnsentBoxes(unsentBoxes):
                state.unsentBoxes.append(contentsOf: unsentBoxes)
                return .none

            // 낙관적 업데이트 방식으로 성공 시 화면에 반영
            case let ._setDeletedBox(boxId):
                state.sentBoxes.remove(id: boxId)
                state.receivedBoxes.remove(id: boxId)
                state.unsentBoxes.remove(id: boxId)
                return .none

            case let ._setFetchBoxLoading(isLoading):
                state.isFetchBoxesLoading = isLoading
                return .none

            case let ._setShowDetailLoading(isLoading):
                state.isShowDetailLoading = isLoading
                return .none

            case .delegate:
                return .none
            }
        }
    }
}

private extension MyBoxFeature {
    func fetchAllInitialGiftBoxes(_ state: State) -> Effect<Action> {
        guard state.sentBoxes.isEmpty && state.receivedBoxes.isEmpty else { return .none }
        return .merge(
            fetchGiftBoxes(type: .received, lastGiftBoxDate: nil),
            fetchGiftBoxes(type: .sent, lastGiftBoxDate: nil)
        )
    }

    func fetchGiftBoxes(type: GiftBoxType, lastGiftBoxDate: Date?) -> Effect<Action> {
        .run { send in
            do {
                let giftBoxesData = try await boxClient.fetchGiftBoxes(
                    .init(
                        lastGiftBoxDate: lastGiftBoxDate?.formattedString(by: .serverDateTime),
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

    func fetchUnsentBoxes() -> Effect<Action> {
        .run { send in
            do {
                let unsentBoxes = try await boxClient.fetchUnsentBoxes()
                await send(._setUnsentBoxes(unsentBoxes))
            } catch {
                print("🐛 \(error)")
            }
        }
    }
}
