//
//  ManageAccountFeature.swift
//  Packy
//
//  Created Mason Kim on 2/4/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ManageAccountFeature: Reducer {

    @ObservableState
    struct State: Equatable {
        let socialLoginProvider: SocialLoginProvider?
    }

    enum Action: ViewAction {
        case view(View)

        enum View {
            case onTask
            case backButtonTapped
        }
    }

    @Dependency(\.dismiss) var dismiss

    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case let .view(action):
                switch action {
                case .onTask:
                    return .none
                    
                case .backButtonTapped:
                    return .run { _ in await dismiss() }
                }
            }
        }
    }
}
