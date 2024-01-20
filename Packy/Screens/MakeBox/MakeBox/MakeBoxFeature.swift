//
//  MakeBoxFeature.swift
//  Packy
//
//  Created Mason Kim on 1/14/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct MakeBoxFeature: Reducer {

    struct State: Equatable {
        @BindingState var boxSendTo: String = ""
        @BindingState var boxSendFrom: String = ""
        var nextButtonEnabled: Bool {
            !boxSendTo.isEmpty && !boxSendFrom.isEmpty
        }

        var path: StackState<MakeBoxNavigationPath.State> = .init()
    }

    enum Action: BindableAction {
        // MARK: User Action
        case binding(BindingAction<State>)

        // MARK: Inner Business Action
        case _onTask

        // MARK: Inner SetState Action

        // MARK: Child Action
        case path(StackAction<MakeBoxNavigationPath.State, MakeBoxNavigationPath.Action>)
    }


    var body: some Reducer<State, Action> {
        BindingReducer()
        navigationReducer

        Reduce<State, Action> { state, action in
            switch action {
            case .binding(\.$boxSendFrom):
                print("FROM!!!")
                return .none

            case ._onTask:
                return .none
                
            case .path:
                return .none

            default:
                return .none
            }
        }
    }
}
