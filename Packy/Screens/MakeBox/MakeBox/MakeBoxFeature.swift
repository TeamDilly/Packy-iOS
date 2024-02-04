//
//  MakeBoxFeature.swift
//  Packy
//
//  Created Mason Kim on 1/14/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct MakeBoxFeature: Reducer {

    struct State: Equatable {
        @BindingState var boxSendTo: String = ""
        @BindingState var boxSendFrom: String = ""
        var nextButtonEnabled: Bool {
            !boxSendTo.isEmpty && !boxSendFrom.isEmpty
        }
    }

    @Dependency(\.dismiss) var dismiss

    enum Action: BindableAction {
        // MARK: User Action
        case binding(BindingAction<State>)
        case backButtonTapped

        // MARK: Inner Business Action
        case _onTask
    }


    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce<State, Action> { state, action in
            switch action {
            case .backButtonTapped:
                return .run { _ in await dismiss() }

            default:
                return .none
            }
        }
    }
}
