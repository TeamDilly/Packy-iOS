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
        var path: StackState<MakeBoxNavigationPath.State> = .init()
    }

    enum Action {
        // MARK: User Action

        // MARK: Inner Business Action
        case _onTask

        // MARK: Inner SetState Action

        // MARK: Child Action
        case path(StackAction<MakeBoxNavigationPath.State, MakeBoxNavigationPath.Action>)
    }


    var body: some Reducer<State, Action> {
        navigationReducer

        Reduce<State, Action> { state, action in
            switch action {
            case ._onTask:
                return .none
                
            case .path:
                return .none
            }
        }
    }
}
