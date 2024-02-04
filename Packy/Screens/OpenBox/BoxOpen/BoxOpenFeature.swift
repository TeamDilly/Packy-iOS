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

        // MARK: Delegate Action
        enum Delegate {
            case moveToBoxDetail(ReceivedGiftBox)
        }
        case delegate(Delegate)
    }

    @Dependency(\.boxClient) var boxClient
    @Dependency(\.continuousClock) var clock

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
                guard let giftBox = state.giftBox else { return .none }
                state.showingState = .openMotion
                return .run { send in
                    try? await clock.sleep(for: .seconds(3)) // TODO: 모션디자인 시간만큼 지연
                    await send(.delegate(.moveToBoxDetail(giftBox)))
                }

            case let ._setReceivedGiftBox(giftBox):
                state.giftBox = giftBox
                return .none

            default:
                return .none
            }
        }
    }
}
