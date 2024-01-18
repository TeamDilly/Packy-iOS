//
//  SignUpFeature+Navigation.swift
//  Packy
//
//  Created Mason Kim on 1/9/24.
//

import ComposableArchitecture

// MARK: - Navigation Path

@Reducer
struct SignUpNavigationPath {
    enum State: Equatable {
        case profile(SignUpProfileFeature.State)
        case termsAgreement(TermsAgreementFeature.State)
    }

    enum Action {
        case profile(SignUpProfileFeature.Action)
        case termsAgreement(TermsAgreementFeature.Action)
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.profile, action: \.profile) { SignUpProfileFeature() }
        Scope(state: \.termsAgreement, action: \.termsAgreement) { TermsAgreementFeature() }
    }
}

// MARK: - Navigation Reducer

extension SignUpNicknameFeature {
    var navigationReducer: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .path(action):
                switch action {
                case .element(id: _, action: .termsAgreement(.delegate(.completedSignUp))):
                    return .send(.delegate(.completeSignUp))

                default:
                    return .none
                }

            default:
                return .none
            }
        }
    }
}
