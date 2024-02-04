//
//  HomeFeature.swift
//  Packy
//
//  Created Mason Kim on 2/4/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct HomeFeature: Reducer {

    struct State: Equatable {
        var path: StackState<HomeNavigationPath.State> = .init()
    }

    enum Action {
        // MARK: User Action

        // MARK: Inner Business Action
        case _onTask

        // MARK: Inner SetState Action

        // MARK: Child Action
        case path(StackAction<HomeNavigationPath.State, HomeNavigationPath.Action>)
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
