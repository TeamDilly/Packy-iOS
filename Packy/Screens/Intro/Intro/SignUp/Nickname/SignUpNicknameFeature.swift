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

    enum Action: ViewAction {
        case view(View)
        case delegate(Delegate)

        // MARK: Child Action
        case path(StackAction<SignUpNavigationPath.State, SignUpNavigationPath.Action>)

        enum View: BindableAction {
            case onTask
            case binding(BindingAction<State>)
        }

        enum Delegate {
            case completeSignUp
        }
    }


    var body: some Reducer<State, Action> {
        BindingReducer(action: \.view)

        EmptyReducer()
            .forEach(\.path, action: /Action.path) {
                SignUpNavigationPath()
            }

        navigationReducer
    }
}
