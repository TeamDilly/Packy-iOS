//
//  SignUpProfileFeature.swift
//  Packy
//
//  Created Mason Kim on 1/9/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct SignUpProfileFeature: Reducer {

    struct State: Equatable {
        @BindingState var textInput: String = ""
    }

    enum Action: BindableAction {
        // MARK: User Action
        case binding(BindingAction<State>)

        // MARK: Inner Business Action
        case _onAppear

        // MARK: Inner SetState Action

        // MARK: Child Action
        
    }


    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce<State, Action> { state, action in
            switch action {
            case .binding:
                return .none

            case ._onAppear:
                return .none
                
            default:
                return .none
            }
        }
    }
}
