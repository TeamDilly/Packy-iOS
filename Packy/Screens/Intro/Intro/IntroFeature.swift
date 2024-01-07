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
        case termsAgreement(TermsAgreementFeature.State = .init())

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
        case termsAgreement(TermsAgreementFeature.Action)
    }

    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case ._onAppear:
                return .none

            case let ._changeScreen(newState):
                state = newState
                return .none

            default:
                return .none
            }
        }
        .ifCaseLet(\.onboarding, action: \.onboarding) { OnboardingFeature() }
        .ifCaseLet(\.login, action: \.login) { LoginFeature() }
        .ifCaseLet(\.termsAgreement, action: \.termsAgreement) { TermsAgreementFeature() }
    }
}
