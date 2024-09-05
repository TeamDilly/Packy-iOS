//
//  HomeFeature.swift
//  Packy
//
//  Created Mason Kim on 2/4/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct HomeFeature: Reducer {

    @ObservableState
    struct State: Equatable {
        var giftBoxes: [SentReceivedGiftBox] = []
        var unsentBoxes: IdentifiedArrayOf<UnsentBox> = []
        var isShowDetailLoading: Bool = false

        var selectedBoxToDelete: UnsentBox?
        var notices: [Notice] = []
    }

    enum Action: ViewAction {
        case view(View)
        case delegate(Delegate)

        case deleteBox(Int)
        case setGiftBoxes([SentReceivedGiftBox])
        case setUnsentBoxes([UnsentBox])
        case setShowDetailLoading(Bool)
        case setDeletedBox(Int)
        case setNotices([Notice])

        enum View: BindableAction {
            case onTask
            case binding(BindingAction<State>)
            case tappedGiftBox(boxId: Int)
            case tappedUnsentBox(boxId: Int)
            case viewMoreButtonTapped
            case deleteBottomMenuConfirmButtonTapped
            case noticeBannerTapped(Notice)
        }

        enum Delegate {
            case moveToBoxDetail(boxId: Int, ReceivedGiftBox, isForSend: Bool)
            case moveToMyBox
            case moveToWebView(url: String)
        }
    }

    @Dependency(\.authClient) var authClient
    @Dependency(\.boxClient) var boxClient
    @Dependency(\.adminClient) var adminClient
    @Dependency(\.packyAlert) var packyAlert
    @Dependency(\.bottomMenu) var bottomMenu

    var body: some Reducer<State, Action> {
        BindingReducer(action: \.view)

        Reduce<State, Action> { state, action in
            switch action {
            case let .view(action):
                switch action {
                case .onTask:
                    return .merge(
                        fetchGiftBoxes(),
                        fetchUnsentBoxes(),
                        fetchNotices()
                    )

                case .binding(\.selectedBoxToDelete):
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

                case let .tappedGiftBox(boxId):
                    state.isShowDetailLoading = true
                    return .run { send in
                        do {
                            let giftBox = try await boxClient.openGiftBox(boxId)
                            await send(.delegate(.moveToBoxDetail(boxId: boxId, giftBox, isForSend: false)))
                            await send(.setShowDetailLoading(false))
                        } catch {
                            print("🐛 \(error)")
                            await send(.setShowDetailLoading(false))
                        }
                    }

                case let .tappedUnsentBox(boxId):
                    state.isShowDetailLoading = true
                    return .run { send in
                        do {
                            let giftBox = try await boxClient.openGiftBox(boxId)
                            await send(.delegate(.moveToBoxDetail(boxId: boxId, giftBox, isForSend: true)))
                            await send(.setShowDetailLoading(false))
                        } catch {
                            print("🐛 \(error)")
                            await send(.setShowDetailLoading(false))
                        }
                    }

                case .viewMoreButtonTapped:
                    return .send(.delegate(.moveToMyBox))

                case .deleteBottomMenuConfirmButtonTapped:
                    guard let selectedBoxIdToDelete = state.selectedBoxToDelete?.id else { return .none }
                    return .run { send in
                        await packyAlert.show(
                            .init(
                                title: "선물박스를 삭제할까요?",
                                description: "선물박스에 들어있는 모든 선물들이 사라져요\n삭제한 선물박스는 다시 볼 수 없어요",
                                cancel: "취소",
                                confirm: "삭제",
                                confirmAction: {
                                    await send(.deleteBox(selectedBoxIdToDelete))
                                }
                            )
                        )
                    }

                case let .noticeBannerTapped(notice):
                    guard let noticeUrl = notice.noticeUrl else { return .none }
                    return .send(.delegate(.moveToWebView(url: noticeUrl)))

                default:
                    return .none
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

            // MARK: Inner SetState Action
            // 낙관적 업데이트 방식으로 성공 시 화면에 반영
            case let .setDeletedBox(boxId):
                state.unsentBoxes.remove(id: boxId)
                return .none

            case let .setGiftBoxes(giftBoxes):
                state.giftBoxes = giftBoxes
                return .none

            case let .setUnsentBoxes(unsentBoxes):
                state.unsentBoxes = .init(uniqueElements: unsentBoxes)
                return .none

            case let .setShowDetailLoading(isLoading):
                state.isShowDetailLoading = isLoading
                return .none

            case let .setNotices(notices):
                state.notices = notices
                return .none

            // MARK: Child Action
            case .delegate:
                return .none
            }
        }
    }
}

// MARK: - Inner Functions

private extension HomeFeature {
    func fetchGiftBoxes() -> Effect<Action> {
        .run { send in
            do {
                let giftBoxesData = try await boxClient.fetchGiftBoxes(.init())
                await send(.setGiftBoxes(giftBoxesData.giftBoxes), animation: .spring)
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

    func fetchNotices() -> Effect<Action> {
        .run { send in
            do {
                let notices = try await adminClient.fetchNotices()
                await send(.setNotices(notices), animation: .spring)
            } catch {
                print("🐛 \(#function) \(error)")
            }
        }
    }
}
