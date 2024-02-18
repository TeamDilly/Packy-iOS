//
//  LetterArchiveFeature.swift
//  Packy
//
//  Created Mason Kim on 2/18/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct LetterArchiveFeature: Reducer {

    struct State: Equatable {
    }

    enum Action {
        // MARK: User Action

        // MARK: Inner Business Action
        case _onTask

        // MARK: Inner SetState Action
    }


    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case ._onTask:
                return .none
            }
        }
    }
}
