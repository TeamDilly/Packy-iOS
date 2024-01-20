//
//  BoxChoiceFeature.swift
//  Packy
//
//  Created Mason Kim on 1/14/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct BoxChoiceFeature: Reducer {

    struct PassingData {
        let senderInfo: BoxSenderInfo
        let selectedBoxIndex: Int
    }

    struct State: Equatable {
        let senderInfo: BoxSenderInfo
        @BindingState var selectedBox: Int = 0
        @BindingState var selectedMessage: Int = 0
        var isPresentingFinishedMotionView: Bool = false
    }

    enum Action: BindableAction {
        // MARK: User Action
        case binding(BindingAction<State>)
        case selectBox(_ index: Int)
        case nextButtonTapped

        // MARK: Inner Business Action
        case _onTask

        // MARK: Inner SetState Action
        case _setIsPresentingFinishedMotionView(Bool)

        // MARK: Delegate Action
        enum Delegate {
            case moveToBoxStartGuide(PassingData)
        }
        case delegate(Delegate)
    }

    @Dependency(\.continuousClock) var clock

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce<State, Action> { state, action in
            switch action {
            case .binding:
                return .none
                
            case ._onTask:
                return .none

            case .nextButtonTapped:
                return .run { [state] send in
                    await send(._setIsPresentingFinishedMotionView(true))
                    try? await clock.sleep(for: .seconds(3)) // 애니메이션 부여 시간 만큼... 지연
                    await send(.delegate(.moveToBoxStartGuide(.init(senderInfo: state.senderInfo, selectedBoxIndex: state.selectedBox))))
                    try? await clock.sleep(for: .seconds(0.1))
                    await send(._setIsPresentingFinishedMotionView(false))
                }

            case let ._setIsPresentingFinishedMotionView(isPresented):
                state.isPresentingFinishedMotionView = isPresented
                return .none

            default:
                return .none
            }
        }
    }
}
