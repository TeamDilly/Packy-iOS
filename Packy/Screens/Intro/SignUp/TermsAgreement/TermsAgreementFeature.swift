//
//  TermsAgreementFeature.swift
//  Packy
//
//  Created Mason Kim on 1/7/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct TermsAgreementFeature: Reducer {

    struct State: Equatable {
        var termsStates: [Terms: Bool] = Terms.allCases.reduce(into: [Terms: Bool]()) {
            $0[$1] = false
        }
        var isAllTermsAgreed: Bool {
            termsStates.allSatisfy { $1 == true }
        }
        var isAllRequiredTermsAgreed: Bool {
            termsStates
                .filter { $0.key.isRequired }
                .allSatisfy { $1 == true }
        }
    }

    enum Action {
        // MARK: Inner Business Action
        case _onAppear
        case backButtonTapped
        case agreeTermsButtonTapped(Terms)
        case agreeAllTermsButtonTapped

        // MARK: Inner SetState Action

        // MARK: Child Action
    }

    @Dependency(\.dismiss) var dismiss
    @Dependency(\.continuousClock) var clock

    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case ._onAppear:
                return .run { send in
                    try await clock.sleep(for: .seconds(1))
                    await ATTManager.requestAuthorization()
                }

            case .backButtonTapped:
                return .run { _ in
                    await dismiss()
                }

            case let .agreeTermsButtonTapped(terms):
                state.termsStates[terms]?.toggle()
                return .none

            case .agreeAllTermsButtonTapped:
                if state.isAllTermsAgreed {
                    Terms.allCases.forEach {
                        state.termsStates[$0] = false
                    }
                } else {
                    Terms.allCases.forEach {
                        state.termsStates[$0] = true
                    }
                }
                // Terms.allCases.forEach {
                //     state.termsStates[$0] = isAllTermsAgreed
                // }
                return .none
            }
        }
    }
}
