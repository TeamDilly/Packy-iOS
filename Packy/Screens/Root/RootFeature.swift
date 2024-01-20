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

        init() { self = .makeBox() }
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

                return .run { send in
                    // TODO: Token 만료 시, refresh token 으로 발급 로직 추가

                    /// AccessToken 존재 시, home 으로 이동
                    if keychain.read(.accessToken) != nil {
                        await send(._changeScreen(.home()))
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
                        return .send(._changeScreen(.home()), animation: .spring)

                    default:
                        return .none
                    }

                default:
                    return .none
                }
            }
                .ifCaseLet(\.intro, action: \.intro) { IntroFeature() }
                .ifCaseLet(\.home, action: \.home) { HomeFeature() }
        }
    }
