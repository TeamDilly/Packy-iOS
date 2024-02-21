//
//  BoxDetailFeature.swift
//  Packy
//
//  Created Mason Kim on 1/29/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct BoxDetailFeature: Reducer {

    enum PresentingState {
        case detail
        case gift
        case photo
        case letter
    }

    @dynamicMemberLookup
    struct State: Equatable {
        let giftBox: ReceivedGiftBox
        let isToSend: Bool
        @BindingState var presentingState: PresentingState = .detail

        subscript<T>(dynamicMember keyPath: KeyPath<ReceivedGiftBox, T>) -> T {
            giftBox[keyPath: keyPath]
        }
    }

    enum Action: BindableAction {
        // MARK: User Action
        case binding(BindingAction<State>)
        case closeButtonTapped
        case backButtonTapped

        // MARK: Inner Business Action
        case _onTask

        // MARK: Inner SetState Action

        // MARK: Delegate Action
        enum Delegate {
            case closeBoxOpen
        }
        case delegate(Delegate)
    }

    @Dependency(\.boxClient) var boxClient
    @Dependency(\.dismiss) var dismiss

    var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .backButtonTapped:
                return .run { _ in await dismiss() }

            case .closeButtonTapped:
                return .send(.delegate(.closeBoxOpen))

            default:
                return .none
            }
        }
    }
}
