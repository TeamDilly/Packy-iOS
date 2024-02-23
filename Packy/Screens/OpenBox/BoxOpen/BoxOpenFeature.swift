//
//  BoxOpenFeature.swift
//  Packy
//
//  Created Mason Kim on 2/3/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct BoxOpenFeature: Reducer {

    enum ShowingState {
        case openBox
        case openMotion
        case openError
    }

    @ObservableState
    struct State: Equatable {
        let boxId: Int
        var showingState: ShowingState = .openBox
        var giftBox: ReceivedGiftBox?
    }

    enum Action {
        // MARK: User Action
        case openBoxButtonTapped
        case closeButtonTapped
        case errorConfirmButtonTapped

        // MARK: Inner Business Action
        case _onTask

        // MARK: Inner SetState Action
        case _setReceivedGiftBox(ReceivedGiftBox)
        case _setShowingState(ShowingState)
        case _showAnimationAndGoToDetail(boxId: Int, ReceivedGiftBox)

        // MARK: Delegate Action
        enum Delegate {
            case moveToBoxDetail(boxId: Int, ReceivedGiftBox)
            case moveToHome
        }
        case delegate(Delegate)
    }

    @Dependency(\.boxClient) var boxClient
    @Dependency(\.continuousClock) var clock
    @Dependency(\.dismiss) var dismiss

    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case ._onTask:
                guard state.giftBox == nil else { return .none }
                let boxId = state.boxId
                return .run { send in
                    do {
                        let giftBox = try await boxClient.openGiftBox(boxId)
                        await send(._setReceivedGiftBox(giftBox))
                    } catch {
                        await send(._setShowingState(.openError), animation: .spring)
                    }
                }

            case .openBoxButtonTapped:
                guard let giftBox = state.giftBox else { return .none }
                let boxId = state.boxId
                state.showingState = .openMotion
                return .send(._showAnimationAndGoToDetail(boxId: boxId, giftBox))
                
            case .closeButtonTapped, .errorConfirmButtonTapped:
                return .send(.delegate(.moveToHome), animation: .spring)

            case let ._setReceivedGiftBox(giftBox):
                state.giftBox = giftBox
                return .none

            case let ._setShowingState(showingState):
                state.showingState = showingState
                return .none

            case let ._showAnimationAndGoToDetail(boxId, giftBox):
                return .run { send in
                    try? await clock.sleep(for: .seconds(Constants.openBoxAnimationDuration))
                    await send(.delegate(.moveToBoxDetail(boxId: boxId, giftBox)))
                    try? await clock.sleep(for: .seconds(0.5))
                    await send(._setShowingState(.openBox))
                }

            default:
                return .none
            }
        }
    }
}
