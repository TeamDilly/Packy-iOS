//
//  PopupGiftBoxFeature.swift
//  Packy
//
//  Created Mason Kim on 2/22/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct PopupGiftBoxFeature: Reducer {

    @ObservableState
    struct State: Equatable {
        /// 패키가 준비한 선물박스
        var popupBox: PopupGiftBox?
    }

    enum Action: ViewAction {
        case view(View)
        case delegate(Delegate)

        case fetchPopupGiftBox
        case hideBottomSheet
        case setPopupGiftBox(PopupGiftBox)

        enum View {
            case openButtonTapped
        }

        enum Delegate {
            case moveToOpenBox(boxId: Int, ReceivedGiftBox)
        }
    }

    @Dependency(\.continuousClock) var clock
    @Dependency(\.boxClient) var boxClient

    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case let .view(action):
                switch action {
                case .openButtonTapped:
                    guard let boxId = state.popupBox?.giftBoxId else { return .none }
                    return .run { send in
                        do {
                            let giftBox = try await boxClient.openGiftBox(boxId)
                            await send(.hideBottomSheet)
                            await send(.delegate(.moveToOpenBox(boxId: boxId, giftBox)))
                        } catch {
                            print("🐛 \(error)")
                        }
                    }
                }

            // MARK: Inner Business Action
            case .fetchPopupGiftBox:
                return fetchPopupGiftBox()

            case .hideBottomSheet:
                state.popupBox = nil
                return .none

            // MARK: Inner SetState Action
            case let .setPopupGiftBox(popupBox):
                state.popupBox = popupBox
                return .none

            case .delegate:
                return .none
            }
        }
    }
}

private extension PopupGiftBoxFeature {
    func fetchPopupGiftBox() -> Effect<Action> {
        .run { send in
            do {
                try await clock.sleep(for: .seconds(1))
                guard let popupBox = try await boxClient.fetchPopupGiftBox(.main) else {
                    print("🎁 보여줄 팝업 박스가 존재하지 않습니다.")
                    return
                }
                await send(.setPopupGiftBox(popupBox))
            } catch {
                print("🐛 \(error)")
            }
        }
    }
}
