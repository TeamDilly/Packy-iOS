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
        let username: String
        @BindingState var boxSendTo: String = ""
        @BindingState var boxSendFrom: String = ""
        var nextButtonEnabled: Bool {
            !boxSendTo.isEmpty && !boxSendFrom.isEmpty
        }
        var hasAnyTextInput: Bool {
            !boxSendTo.isEmpty || !boxSendFrom.isEmpty
        }

        init(username: String) {
            self.username = username
            boxSendFrom = username
        }
    }

    enum Action: BindableAction {
        // MARK: User Action
        case binding(BindingAction<State>)
        case backButtonTapped

        // MARK: Inner Business Action
        case _onTask
    }

    @Dependency(\.dismiss) var dismiss
    @Dependency(\.userDefaults) var userDefaults
    @Dependency(\.packyAlert) var packyAlert

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce<State, Action> { state, action in
            switch action {
            case .backButtonTapped:
                if state.hasAnyTextInput == false {
                    return .run { _ in
                        await dismiss()
                    }
                }

                return .run { send in
                    await packyAlert.show(
                        .init(
                            title: "선물박스 만들기를 종료할까요?",
                            cancel: "취소",
                            confirm: "확인",
                            confirmAction: {
                                await dismiss()
                            }
                        )
                    )
                }

            case ._onTask:
                return .run { _ in
                    await userDefaults.setBool(false, .didEnteredBoxGuide)
                }

            default:
                return .none
            }
        }
    }
}
