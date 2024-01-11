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

        var isATTCompleted: Bool = false
    }

    enum Action {
        // MARK: User Action
        case backButtonTapped
        case agreeTermsButtonTapped(Terms)
        case agreeAllTermsButtonTapped
        case confirmButtonTapped

        // MARK: Inner Business Action
        case _onAppear

        // MARK: Inner SetState Action
        case _setATTCompleted

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
                }

            case .backButtonTapped:
                return .run { _ in
                    await dismiss()
                }

            case .confirmButtonTapped:
                return .run { send in
                    _ = await ATTManager.requestAuthorization()

                    // 여기서 종료하고, 네비게이팅 하면 됨.
                    await send(._setATTCompleted)
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

            case ._setATTCompleted:
                state.isATTCompleted = true
                return .none
            }
        }
    }
}
