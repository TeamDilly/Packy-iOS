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
    }

    enum Action {
        // MARK: Inner Business Action
        case _onAppear

        // MARK: Inner SetState Action

        // MARK: Child Action
    }


    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case ._onAppear:
                return .none
            }
        }
    }
}
