//
//  BoxDetailFeature.swift
//  Packy
//
//  Created Mason Kim on 1/29/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct BoxDetailFeature: Reducer {

    @dynamicMemberLookup
    struct State: Equatable {
        let giftBox: GiftBox = .mock

        subscript<T>(dynamicMember keyPath: KeyPath<GiftBox, T>) -> T {
            giftBox[keyPath: keyPath]
        }
    }

    enum Action {
        // MARK: User Action

        // MARK: Inner Business Action
        case _onTask

        // MARK: Inner SetState Action

        // MARK: Child Action
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
