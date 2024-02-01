//
//  BoxAddTitleAndShareFeature.swift
//  Packy
//
//  Created Mason Kim on 1/27/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct BoxAddTitleAndShareFeature: Reducer {

    enum ShowingState {
        case addTitle
        case completed
        case send
    }

    struct State: Equatable {
        var giftBox: SendingGiftBox
        let boxDesign: BoxDesign
        @BindingState var boxNameInput: String = ""
        @BindingState var showingState: ShowingState = .addTitle
    }

    enum Action: BindableAction {
        // MARK: User Action
        case binding(BindingAction<State>)
        case backButtonTapped
        case nextButtonTapped

        // MARK: Inner Business Action
        case _onTask

        // MARK: Inner SetState Action

        // MARK: Child Action
    }

    @Dependency(\.continuousClock) var clock
    @Dependency(\.boxClient) var boxClient
    @Dependency(\.dismiss) var dismiss

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce<State, Action> { state, action in
            switch action {
            case .binding:
                return .none

            case .backButtonTapped:
                return .run { _ in await dismiss() }

            case .nextButtonTapped:
                state.giftBox.name = state.boxNameInput
                return .concatenate(
                    // 저장
                    saveGiftBox(state.giftBox),

                    // 이후 화면 전환
                    .run { send in
                        await send(.binding(.set(\.$showingState, .completed)), animation: .spring)
                        try? await clock.sleep(for: .seconds(1.5))
                        await send(.binding(.set(\.$showingState, .send)), animation: .spring(duration: 1))
                    }
                )

            case ._onTask:
                return .none
            }
        }
    }
}


// MARK: - Inner Functions

private extension BoxAddTitleAndShareFeature {
    func saveGiftBox(_ giftBox: SendingGiftBox) -> Effect<Action> {
        return .run { send in
            do {
                let response = try await boxClient.makeGiftBox(giftBox)
                print(response)
            } catch {
                print(error)
            }
        }
    }
}
