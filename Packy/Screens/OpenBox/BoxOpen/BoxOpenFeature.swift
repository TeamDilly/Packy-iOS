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
        case onTask

        // MARK: Inner SetState Action
        case setReceivedGiftBox(ReceivedGiftBox)
        case setShowingState(ShowingState)
        case showAnimationAndGoToDetail(boxId: Int, ReceivedGiftBox)

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
            case .onTask:
                guard state.giftBox == nil else { return .none }
                let boxId = state.boxId
                return .run { send in
                    do {
                        let giftBox = try await boxClient.openGiftBox(boxId)
                        await send(.setReceivedGiftBox(giftBox))
                    } catch {
                        await send(.setShowingState(.openError), animation: .spring)
                    }
                }

            case .openBoxButtonTapped:
                guard let giftBox = state.giftBox else { return .none }
                let boxId = state.boxId
                state.showingState = .openMotion
                return .send(.showAnimationAndGoToDetail(boxId: boxId, giftBox))
                
            case .closeButtonTapped, .errorConfirmButtonTapped:
                return .send(.delegate(.moveToHome), animation: .spring)

            case let .setReceivedGiftBox(giftBox):
                state.giftBox = giftBox
                return .none

            case let .setShowingState(showingState):
                state.showingState = showingState
                return .none

            case let .showAnimationAndGoToDetail(boxId, giftBox):
                return .run { send in
                    try? await clock.sleep(for: .seconds(Constants.openBoxAnimationDuration))
                    await send(.delegate(.moveToBoxDetail(boxId: boxId, giftBox)))
                    try? await clock.sleep(for: .seconds(0.5))
                    await send(.setShowingState(.openBox))
                }

            default:
                return .none
            }
        }
    }
}
