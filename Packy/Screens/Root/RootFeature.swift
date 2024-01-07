//
//  RootFeature.swift
//  Packy
//
//  Created Mason Kim on 1/7/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct RootFeature: Reducer {

    enum State: Equatable {
        case intro(IntroFeature.State = .init())
        case home(HomeFeature.State = .init())

        init() { self = .intro() }
    }

    enum Action {
        // MARK: User Action

        // MARK: Inner Business Action
        case _onAppear

        // MARK: Inner SetState Action

        // MARK: Child Action
        case intro(IntroFeature.Action)
        case home(HomeFeature.Action)
    }


    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case ._onAppear:
                return .none
            default:
                return .none
            }
        }
        .ifCaseLet(\.intro, action: \.intro) { IntroFeature() }
        .ifCaseLet(\.home, action: \.home) { HomeFeature() }
    }
}
