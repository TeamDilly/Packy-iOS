//
//  RootFeature.swift
//  Packy
//
//  Created Mason Kim on 1/7/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct RootFeature: Reducer {

    enum State: Equatable {
        case intro(IntroFeature.State = .init())
        case home(HomeFeature.State = .init())
        case makeBox(MakeBoxFeature.State = .init())

        init() { self = .intro() }
    }

    enum Action {
        // MARK: User Action

        // MARK: Inner Business Action
        case _onAppear
        case _changeScreen(State)

        // MARK: Inner SetState Action

        // MARK: Child Action
        case intro(IntroFeature.Action)
        case home(HomeFeature.Action)
        case makeBox(MakeBoxFeature.Action)
    }

    @Dependency(\.socialLogin) var socialLogin
    @Dependency(\.userDefaults) var userDefaults
    @Dependency(\.keychain) var keychain

    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case ._onAppear:
                socialLogin.initKakaoSDK()

                // TODO: 테스트를 위한 로직 (토큰 삭제)
                // keychain.delete(.accessToken)
                // keychain.delete(.refreshToken)

                return .run { send in
                    /// AccessToken 존재 시, home 으로 이동
                    if keychain.read(.accessToken) != nil {
                        // TODO: 테스트를 위해 makeBox로 이동하도록 처리. 차후 home 으로 변경 필요
                        await send(._changeScreen(.makeBox()), animation: .spring)
                    }

                    await userDefaults.setBool(true, .isPopGestureEnabled)
                }

            case let ._changeScreen(newState):
                state = newState
                return .none

            case let .intro(action):
                switch action {
                    // 로그인 완료, 회원가입 완료 시 홈으로 이동
                case .login(.delegate(.completeLogin)),
                     .signUp(.delegate(.completeSignUp)):
                    return .send(._changeScreen(.makeBox()), animation: .spring)

                default:
                    return .none
                }

            default:
                return .none
            }
        }
        .ifCaseLet(\.intro, action: \.intro) { IntroFeature() }
        .ifCaseLet(\.home, action: \.home) { HomeFeature() }
        .ifCaseLet(\.makeBox, action: \.makeBox) { MakeBoxFeature() }
    }
}
