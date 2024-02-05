//
//  SplashFeature.swift
//  Packy
//
//  Created Mason Kim on 2/5/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct SplashFeature: Reducer {

    struct State: Equatable {}

    enum Action {
        case _onTask
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
