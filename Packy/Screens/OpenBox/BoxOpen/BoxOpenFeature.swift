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
    }

    struct State: Equatable {
        let boxId: Int
        var showingState: ShowingState = .openBox
        var giftBox: ReceivedGiftBox?
    }

    enum Action {
        // MARK: User Action
        case openBoxButtonTapped

        // MARK: Inner Business Action
        case _onTask

        // MARK: Inner SetState Action
        case _setReceivedGiftBox(ReceivedGiftBox)

        // MARK: Child Action

    }

    @Dependency(\.boxClient) var boxClient

    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case ._onTask:
                let boxId = state.boxId
                return .run { send in
                    let giftBox = try await boxClient.openGiftBox(boxId)
                    await send(._setReceivedGiftBox(giftBox))
                }

            case .openBoxButtonTapped:
                state.showingState = .openMotion
                return .none

            case let ._setReceivedGiftBox(giftBox):
                state.giftBox = giftBox
                return .none
            }
        }
    }
}
