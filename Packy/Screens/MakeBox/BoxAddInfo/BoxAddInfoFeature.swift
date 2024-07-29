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

    enum Action: ViewAction {
        case view(View)

        case setUsername(String)

        enum View: BindableAction {
            case onTask
            case binding(BindingAction<State>)
            case backButtonTapped
        }
    }

    @Dependency(\.dismiss) var dismiss
    @Dependency(\.userDefaults) var userDefaults
    @Dependency(\.packyAlert) var packyAlert
    @Dependency(\.authClient) var authClient

    var body: some Reducer<State, Action> {
        BindingReducer(action: \.view)

        Reduce<State, Action> { state, action in
            switch action {
            case let .view(action):
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

                case .onTask:
                    return .run { send in
                        await userDefaults.setBool(false, .didEnteredBoxGuide)

                        do {
                            let profile = try await authClient.fetchProfile()
                            await send(.setUsername(profile.nickname))
                        } catch {
                            print("🐛 \(error)")
                        }
                    }

                case .binding:
                    return .none
                }

            case let .setUsername(username):
                state.boxSendFrom = username
                return .none
            }
        }
    }
}
