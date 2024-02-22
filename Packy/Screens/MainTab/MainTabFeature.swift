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
        var archive: ArchiveFeature.State = .init()

        var packyBox: PackyBoxFeature.State = .init()
    }

    enum Action: BindableAction {
        // MARK: User Action
        case binding(BindingAction<State>)

        // MARK: Inner Business Action
        case _onTask

        // MARK: Child Action
        case path(StackAction<MainTabNavigationPath.State, MainTabNavigationPath.Action>)
        case home(HomeFeature.Action)
        case myBox(MyBoxFeature.Action)
        case archive(ArchiveFeature.Action)
        case packyBox(PackyBoxFeature.Action)
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.home, action: \.home) { HomeFeature() }
        Scope(state: \.myBox, action: \.myBox) { MyBoxFeature() }
        Scope(state: \.archive, action: \.archive) { ArchiveFeature() }

        Scope(state: \.packyBox, action: \.packyBox) { PackyBoxFeature() }

        BindingReducer()
        navigationReducer

        Reduce<State, Action> { state, action in
            switch action {

            // MARK: User Action
            case .binding:
                return .none

            // MARK: Inner Business Action
            case ._onTask:
                return .send(.packyBox(._fetchPackyBox))

            // MARK: Child Action
            case .path:
                return .none

            case .home(.delegate(.moveToMyBox)):
                state.selectedTab = .myBox
                return .none

            default:
                return .none
            }
        }
    }
}
