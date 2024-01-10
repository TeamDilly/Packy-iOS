//
//  SignUpNicknameFeature.swift
//  Packy
//
//  Created Mason Kim on 1/9/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct SignUpNicknameFeature: Reducer {

    struct State: Equatable {
        @BindingState var nickname: String = ""
        
        var path: StackState<SignUpNavigationPath.State> = .init()
    }

    enum Action: BindableAction {
        // MARK: User Action
        case binding(BindingAction<State>)
        case saveButtonTapped

        // MARK: Inner Business Action
        case _onAppear

        // MARK: Inner SetState Action

        // MARK: Child Action
        case path(StackAction<SignUpNavigationPath.State, SignUpNavigationPath.Action>)
    }


    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce<State, Action> { state, action in
            switch action {
            case .binding:
                return .none

            case .saveButtonTapped:
                return .none

            case ._onAppear:
                return .none

            default:

                // TODO: path를 순회하며, 각 상태값을 뽑아서 저장하는 형태로 로직 처리...
                /**
                for id in state.path.ids {
                    guard let pathState = state.path[id: id] else { continue }
                    switch pathState {
                    case let .profile(profileState):
                        // 입력된 프로필
                        profileState.textInput
                        return .none
                    case let .termsAgreement(termsAgreementState):
                        // 허용된 약관
                        termsAgreementState.termsStates
                        return .none
                    }
                }
                 */

                return .none
            }
        }
        .forEach(\.path, action: /Action.path) {
            SignUpNavigationPath()
        }

        navigationReducer
    }
}
