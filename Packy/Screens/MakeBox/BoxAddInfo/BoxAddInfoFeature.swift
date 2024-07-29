//
//  BoxAddInfoFeature.swift
//  Packy
//
//  Created Mason Kim on 1/14/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct BoxAddInfoFeature: Reducer {

    @ObservableState
    struct State: Equatable {
        var boxSendTo: String = ""
        var boxSendFrom: String = ""
        var nextButtonEnabled: Bool {
            !boxSendTo.isEmpty && !boxSendFrom.isEmpty
        }
        var hasAnyTextInput: Bool {
            !boxSendTo.isEmpty || !boxSendFrom.isEmpty
        }
    }

    enum Action: BindableAction {
        // MARK: User Action
        case binding(BindingAction<State>)
        case backButtonTapped

        // MARK: Inner Business Action
        case onTask
        case _setUsername(String)
    }

    @Dependency(\.dismiss) var dismiss
    @Dependency(\.userDefaults) var userDefaults
    @Dependency(\.packyAlert) var packyAlert
    @Dependency(\.authClient) var authClient

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

            case let ._setUsername(username):
                state.boxSendFrom = username
                return .none

            case .onTask:
                return .run { send in
                    await userDefaults.setBool(false, .didEnteredBoxGuide)

                    do {
                        let profile = try await authClient.fetchProfile()
                        await send(._setUsername(profile.nickname))
                    } catch {
                        print("🐛 \(error)")
                    }
                }

            default:
                return .none
            }
        }
    }
}
