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

    @ObservableState
    struct State: Equatable {
        var selectedTab: MyBoxTab = .sentBox

        fileprivate var receivedBoxesData: [SentReceivedGiftBoxPageData] = []
        fileprivate var sentBoxesData: [SentReceivedGiftBoxPageData] = []

        var isReceivedBoxesLastPage: Bool { receivedBoxesData.last?.isLastPage ?? true }
        var isSentBoxesLastPage: Bool { sentBoxesData.last?.isLastPage ?? true }

        var receivedBoxes: IdentifiedArrayOf<SentReceivedGiftBox> = []
        var sentBoxes: IdentifiedArrayOf<SentReceivedGiftBox> = []
        var unsentBoxes: IdentifiedArrayOf<UnsentBox> = []

        var selectedBoxIdToDelete: Int?

        var isFetchBoxesLoading: Bool = true
        var isShowDetailLoading: Bool = false
    }

    enum Action: ViewAction {
        case view(View)
        case delegate(Delegate)

        case resetAndFetchAllGiftBoxes
        case deleteBox(Int)
        case setGiftBoxData(SentReceivedGiftBoxPageData, GiftBoxType)
        case setFetchBoxLoading(Bool)
        case setShowDetailLoading(Bool)
        case setDeletedBox(Int)
        case setUnsentBoxes([UnsentBox])

        enum View: BindableAction {
            case onTask
            case didActiveScene
            case binding(BindingAction<State>)
            case tappedGiftBox(boxId: Int, isUnsent: Bool)
            case deleteBottomMenuConfirmButtonTapped
            case fetchMoreSentGiftBoxes
            case fetchMoreReceivedGiftBoxes
        }

        // MARK: Delegate Action
        enum Delegate {
            case moveToBoxDetail(boxId: Int, ReceivedGiftBox, isToSend: Bool)
        }
    }

    @Dependency(\.boxClient) var boxClient
    @Dependency(\.bottomMenu) var bottomMenu
    @Dependency(\.packyAlert) var packyAlert

    var body: some Reducer<State, Action> {
        BindingReducer(action: \.view)

        Reduce<State, Action> { state, action in
            switch action {
            case let .view(action):
                switch action {
                case .onTask:
                    return .merge(
                        fetchAllInitialGiftBoxes(state),
                        fetchUnsentBoxes()
                    )
                    
                case .didActiveScene:
                    return .send(.resetAndFetchAllGiftBoxes)
                    
                case .binding(\.selectedBoxIdToDelete):
                    return .run { send in
                        await bottomMenu.show(
                            .init(
                                confirmTitle: "삭제하기",
                                confirmAction: {
                                    await send(.view(.deleteBottomMenuConfirmButtonTapped))
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
                            await send(.setShowDetailLoading(false))
                        } catch {
                            print("🐛 \(error)")
                            await send(.setShowDetailLoading(false))
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
                                    await send(.deleteBox(selectedBoxIdToDelete), animation: .spring)
                                }
                            )
                        )
                    }

                case .fetchMoreSentGiftBoxes:
                    guard let lastBoxData = state.sentBoxesData.last,
                          lastBoxData.isLastPage == false,
                          let lastBoxDate = lastBoxData.giftBoxes.last?.giftBoxDate else { return .none }

                    return fetchGiftBoxes(
                        type: .sent,
                        lastGiftBoxDate: lastBoxDate
                    )

                case .fetchMoreReceivedGiftBoxes:
                    guard let lastBoxData = state.receivedBoxesData.last,
                          lastBoxData.isLastPage == false,
                          let lastBoxDate = lastBoxData.giftBoxes.last?.giftBoxDate else { return .none }

                    return fetchGiftBoxes(
                        type: .received,
                        lastGiftBoxDate: lastBoxDate
                    )
                }

            case let .deleteBox(boxId):
                return .run { send in
                    do {
                        try await boxClient.deleteGiftBox(boxId)
                        await send(.setDeletedBox(boxId), animation: .spring)
                    } catch {
                        print("🐛 \(error)")
                    }
                }

            case .resetAndFetchAllGiftBoxes:
                state = .init()
                state.isFetchBoxesLoading = true
                return .merge(
                    fetchAllInitialGiftBoxes(state),
                    fetchUnsentBoxes()
                )

            case let .setGiftBoxData(giftBoxData, type):
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

            case let .setUnsentBoxes(unsentBoxes):
                state.unsentBoxes = .init(uniqueElements: unsentBoxes)
                return .none

            // 낙관적 업데이트 방식으로 성공 시 화면에 반영
            case let .setDeletedBox(boxId):
                state.sentBoxes.remove(id: boxId)
                state.receivedBoxes.remove(id: boxId)
                state.unsentBoxes.remove(id: boxId)
                return .none

            case let .setFetchBoxLoading(isLoading):
                state.isFetchBoxesLoading = isLoading
                return .none

            case let .setShowDetailLoading(isLoading):
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
                await send(.setGiftBoxData(giftBoxesData, type), animation: .spring)
                await send(.setFetchBoxLoading(false), animation: .spring)
            } catch {
                print("🐛 \(error)")
            }
        }
    }

    func fetchUnsentBoxes() -> Effect<Action> {
        .run { send in
            do {
                let unsentBoxes = try await boxClient.fetchUnsentBoxes()
                await send(.setUnsentBoxes(unsentBoxes), animation: .spring)
            } catch {
                print("🐛 \(error)")
            }
        }
    }
}
