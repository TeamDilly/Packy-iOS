//
//  HomeFeature+Navigation.swift
//  Packy
//
//  Created Mason Kim on 2/4/24.
//

import ComposableArchitecture

// MARK: - Navigation Path

@Reducer
struct HomeNavigationPath {
    enum State: Equatable {
        case myBox(MyBoxFeature.State = .init())
        case boxDetail(BoxDetailFeature.State)
        case setting(SettingFeature.State)
    }

    enum Action {
        case myBox(MyBoxFeature.Action)
        case boxDetail(BoxDetailFeature.Action)
        case setting(SettingFeature.Action)
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.myBox, action: \.myBox) { MyBoxFeature() }
        Scope(state: \.boxDetail, action: \.boxDetail) { BoxDetailFeature() }
        Scope(state: \.setting, action: \.setting) { SettingFeature() }
    }
}

// MARK: - Navigation Reducer

extension HomeFeature {
    var navigationReducer: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .path(action):
                switch action {
                case .element:
                    return .none

                default:
                    return .none
                }

            default:
                return .none
            }
        }
        .forEach(\.path, action: /Action.path) {
            HomeNavigationPath()
        }
    }
}
