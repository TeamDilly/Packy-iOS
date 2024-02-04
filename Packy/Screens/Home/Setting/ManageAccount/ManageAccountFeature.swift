//
//  ManageAccountFeature.swift
//  Packy
//
//  Created Mason Kim on 2/4/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ManageAccountFeature: Reducer {

    struct State: Equatable {
    }

    enum Action {
        // MARK: User Action
        case backButtonTapped

        // MARK: Inner Business Action
        case _onTask

        // MARK: Inner SetState Action

        // MARK: Child Action
    }

    @Dependency(\.dismiss) var dismiss

    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case ._onTask:
                return .none

            case .backButtonTapped:
                return .run { _ in await dismiss() }
            }
        }
    }
}
