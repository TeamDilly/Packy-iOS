//
//  IntroFeature.swift
//  Packy
//
//  Created Mason Kim on 1/7/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct IntroFeature: Reducer {

    enum State: Equatable {
        case onboarding(OnboardingFeature.State = .init())
        case login(LoginFeature.State = .init())
        case signUp(SignUpNicknameFeature.State = .init())

        init() { self = .onboarding() }
    }

    enum Action {
        // MARK: User Action

        // MARK: Inner Business Action
        case _onAppear

        // MARK: Inner SetState Action
        case _changeScreen(State)

        // MARK: Child Action
        case onboarding(OnboardingFeature.Action)
        case login(LoginFeature.Action)
        case signUp(SignUpNicknameFeature.Action)
    }

    @Dependency(\.userDefaults) var userDefaults

    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case ._onAppear:
                // 이미 온보딩 완료 시, 로그인으로 이동
                if userDefaults.boolForKey(.hasOnboarded) {
                    return .run { send in await send(._changeScreen(.login())) }
                }
                return .none

            case let ._changeScreen(newState):
                state = newState
                return .none

            case .onboarding(.delegate(.completeOnboarding)):
                return .run { send in
                    await send(._changeScreen(.login()), animation: .spring)
                }

            case .login(.delegate(.moveToSignUp)):
                return .send(._changeScreen(.signUp()), animation: .spring)

            default:
                return .none
            }
        }
        .ifCaseLet(\.onboarding, action: \.onboarding) { OnboardingFeature() }
        .ifCaseLet(\.login, action: \.login) { LoginFeature() }
        .ifCaseLet(\.signUp, action: \.signUp) { SignUpNicknameFeature() }
    }
}
