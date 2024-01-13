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

        // MARK: Delegate Action
        enum Delegate {
            case completeLogin
            case moveToSignUp
        }
        case delegate(Delegate)
    }

    @Dependency(\.socialLogin) var socialLogin

    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .kakaoLoginButtonTapped:
                return .run { send in
                    let info = try await socialLogin.kakaoLogin()
                    print(info)

                    // TODO: 서버에서 특정 에러코드 떨어지면 회원가입으로 이동. 일단은 랜덤하게 설정
                    let needSignup = Bool.random()
                    if needSignup {
                        await send(.delegate(.moveToSignUp), animation: .spring)
                    } else {
                        await send(.delegate(.completeLogin), animation: .spring)
                    }
                }

            case .appleLoginButtonTapped:
                return .run { send in
                    let info = try await socialLogin.appleLogin()

                    let needSignup = Bool.random()
                    if needSignup {
                        await send(.delegate(.moveToSignUp), animation: .spring)
                    } else {
                        await send(.delegate(.completeLogin), animation: .spring)
                    }
                }

            case ._onAppear:
                return .none

            default:
                return .none
            }
        }
    }
}
