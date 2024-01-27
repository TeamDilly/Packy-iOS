//
//  BoxAddTitleFeature.swift
//  Packy
//
//  Created Mason Kim on 1/27/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct BoxAddTitleFeature: Reducer {

    enum ShowingState {
        case addTitle
        case completed
        case send
    }

    struct State: Equatable {
        let giftBox: GiftBox
        let boxDesign: BoxDesign
        @BindingState var textInput: String = ""
        @BindingState var showingState: ShowingState = .addTitle
    }

    enum Action: BindableAction {
        // MARK: User Action
        case binding(BindingAction<State>)
        case nextButtonTapped

        // MARK: Inner Business Action
        case _onTask

        // MARK: Inner SetState Action

        // MARK: Child Action
    }

    @Dependency(\.continuousClock) var clock

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce<State, Action> { state, action in
            switch action {
            case .binding:
                return .none

            case .nextButtonTapped:
                return .run { send in
                    await send(.binding(.set(\.$showingState, .completed)), animation: .spring)
                    try? await clock.sleep(for: .seconds(1.5))
                    await send(.binding(.set(\.$showingState, .send)), animation: .spring)
                }

            case ._onTask:
                return .none
            }
        }
    }
}
