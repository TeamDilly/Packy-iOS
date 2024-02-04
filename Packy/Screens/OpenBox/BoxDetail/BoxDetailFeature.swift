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
        @BindingState var presentingState: PresentingState = .detail

        subscript<T>(dynamicMember keyPath: KeyPath<ReceivedGiftBox, T>) -> T {
            giftBox[keyPath: keyPath]
        }
    }

    enum Action: BindableAction {
        // MARK: User Action
        case binding(BindingAction<State>)

        // MARK: Inner Business Action
        case _onTask

        // MARK: Inner SetState Action

        // MARK: Child Action
    }

    @Dependency(\.boxClient) var boxClient

    var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .binding:
                return .none

            case ._onTask:
                return .none
            }
        }
    }
}
