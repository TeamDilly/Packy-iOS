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

    @ObservableState
    struct State: Equatable {
        let socialLoginInfo: SocialLoginInfo
        var nickname: String = ""
        
        var path: StackState<SignUpNavigationPath.State> = .init()

        init(socialLoginInfo: SocialLoginInfo) {
            self.socialLoginInfo = socialLoginInfo
            self.nickname = String(socialLoginInfo.name?.prefix(6) ?? "")
        }
    }

    enum Action: BindableAction {
        // MARK: User Action
        case binding(BindingAction<State>)

        // MARK: Inner Business Action
        case _onAppear

        // MARK: Child Action
        case path(StackAction<SignUpNavigationPath.State, SignUpNavigationPath.Action>)

        enum Delegate {
            case completeSignUp
        }
        case delegate(Delegate)
    }


    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce<State, Action> { state, action in
            switch action {
            case .binding:
                return .none

            case ._onAppear:
                return .none

            default:
                return .none
            }
        }
        .forEach(\.path, action: /Action.path) {
            SignUpNavigationPath()
        }

        navigationReducer
    }
}
