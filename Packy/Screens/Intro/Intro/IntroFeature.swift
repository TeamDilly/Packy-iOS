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

        init() { self = .login() }
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
                // TODO: 릴리즈 시 원상복귀
                // if userDefaults.boolForKey(.hasOnboarded) {
                //     return .run { send in await send(._changeScreen(.login())) }
                // }
                return .none

            case let ._changeScreen(newState):
                state = newState
                return .none

            case .onboarding(.delegate(.didFinishOnboarding)):
                return .run { send in
                    await send(._changeScreen(.login()), animation: .spring)
                }

            default:
                return .none
            }
        }
        .ifCaseLet(\.onboarding, action: \.onboarding) { OnboardingFeature() }
        .ifCaseLet(\.login, action: \.login) { LoginFeature() }
        .ifCaseLet(\.signUp, action: \.signUp) { SignUpNicknameFeature() }
    }
}
