//
//  SignUpNicknameFeature.swift
//  Packy
//
//  Created Mason Kim on 1/9/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct SignUpNicknameFeature: Reducer {

    struct State: Equatable {
        @BindingState var nickname: String = ""
        
        var path: StackState<SignUpNavigationPath.State> = .init()
    }

    enum Action: BindableAction {
        // MARK: User Action
        case binding(BindingAction<State>)
        case saveButtonTapped

        // MARK: Inner Business Action
        case _onAppear

        // MARK: Inner SetState Action

        // MARK: Child Action
        case path(StackAction<SignUpNavigationPath.State, SignUpNavigationPath.Action>)
    }


    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce<State, Action> { state, action in
            switch action {
            case .binding:
                return .none

            case .saveButtonTapped:
                return .none

            case ._onAppear:
                return .none

            default:
                return .none
            }
        }
        .forEach(\.path, action: /Action.path) {
            SignUpNavigationPath()
        }

        navigationReducer
    }
}