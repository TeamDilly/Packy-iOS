//
//  MainTabFeature.swift
//  Packy
//
//  Created Mason Kim on 2/17/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct MainTabFeature: Reducer {

    struct State: Equatable {
        @BindingState var textInput: String = ""
        @BindingState var selectedTab: MainTab = .home

        var path: StackState<MainTabNavigationPath.State> = .init()
        var home: HomeFeature.State = .init()
        var myBox: MyBoxFeature.State = .init()
    }

    enum Action: BindableAction {
        // MARK: User Action
        case binding(BindingAction<State>)

        // MARK: Inner Business Action
        case _onTask

        // MARK: Inner SetState Action

        // MARK: Child Action
        case path(StackAction<MainTabNavigationPath.State, MainTabNavigationPath.Action>)
        case home(HomeFeature.Action)
        case myBox(MyBoxFeature.Action)
    }


    var body: some Reducer<State, Action> {
        Scope(state: \.home, action: \.home) { HomeFeature() }
        Scope(state: \.myBox, action: \.myBox) { MyBoxFeature() }

        BindingReducer()
        navigationReducer

        Reduce<State, Action> { state, action in
            switch action {
            case .binding:
                return .none

            case ._onTask:
                return .none

            case .path:
                return .none

            case .home(.delegate(.moveToMyBox)):
                state.selectedTab = .myBox
                return .none

            case .myBox:
                return .none

            default:
                return .none
            }
        }
    }
}
