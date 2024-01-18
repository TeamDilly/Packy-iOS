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
        let socialLoginInfo: SocialLoginInfo
        let nickName: String

        @BindingState var textInput: String = ""
        var selectedProfileIndex: Int = 0
    }

    enum Action: BindableAction {
        // MARK: User Action
        case binding(BindingAction<State>)
        case backButtonTapped
        case selectProfile(Int)

        // MARK: Inner Business Action
        case _onAppear

        // MARK: Inner SetState Action

        // MARK: Child Action
        
    }

    @Dependency(\.dismiss) var dismiss

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce<State, Action> { state, action in
            switch action {
            case .binding:
                return .none

            case .backButtonTapped:
                return .run { _ in await dismiss() }

            case let .selectProfile(index):
                state.selectedProfileIndex = index
                return .none

            case ._onAppear:
                return .none
                
            default:
                return .none
            }
        }
    }
}
