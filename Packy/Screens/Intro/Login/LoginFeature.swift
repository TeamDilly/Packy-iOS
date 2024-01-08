//
//  LoginFeature.swift
//  Packy
//
//  Created Mason Kim on 1/7/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct LoginFeature: Reducer {

    struct State: Equatable {
    }

    enum Action {
        // MARK: User Action
        case kakaoLoginButtonTapped
        case appleLoginButtonTapped

        // MARK: Inner Business Action
        case _onAppear

        // MARK: Inner SetState Action

        // MARK: Child Action
    }

    @Dependency(\.socialLogin) var socialLogin

    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .kakaoLoginButtonTapped:
                return .none

            case .appleLoginButtonTapped:
                return .run { send in
                    let info = try await socialLogin.appleLogin()
                    print(info)
                }

            case ._onAppear:
                return .none
            }
        }
    }
}
