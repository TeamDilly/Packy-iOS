//
//  BoxChoiceFeature.swift
//  Packy
//
//  Created Mason Kim on 1/14/24.
//

import Foundation
import ComposableArchitecture



@Reducer
struct BoxChoiceFeature: Reducer {

    struct State: Equatable {
        let senderInfo: BoxSenderInfo
        @BindingState var selectedBox: Int = 0
        @BindingState var selectedMessage: Int = 0
    }

    enum Action: BindableAction {
        // MARK: User Action
        case binding(BindingAction<State>)

        // MARK: Inner Business Action
        case _onTask

        // MARK: Inner SetState Action

        // MARK: Child Action
    }

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
