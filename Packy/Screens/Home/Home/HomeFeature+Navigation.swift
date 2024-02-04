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
        case makeBox(MakeBoxFeature.State = .init())
        case myBox(MyBoxFeature.State = .init())
        case boxDetail(BoxDetailFeature.State)
        case setting(SettingFeature.State = .init())
        case manageAccount(ManageAccountFeature.State = .init())
        case deleteAccount(DeleteAccountFeature.State = .init())
    }

    enum Action {
        case makeBox(MakeBoxFeature.Action)
        case myBox(MyBoxFeature.Action)
        case boxDetail(BoxDetailFeature.Action)
        case setting(SettingFeature.Action)
        case manageAccount(ManageAccountFeature.Action)
        case deleteAccount(DeleteAccountFeature.Action)
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.makeBox, action: \.makeBox) { MakeBoxFeature() }
        Scope(state: \.myBox, action: \.myBox) { MyBoxFeature() }
        Scope(state: \.boxDetail, action: \.boxDetail) { BoxDetailFeature() }
        Scope(state: \.setting, action: \.setting) { SettingFeature() }
        Scope(state: \.manageAccount, action: \.manageAccount) { ManageAccountFeature() }
        Scope(state: \.deleteAccount, action: \.deleteAccount) { DeleteAccountFeature() }
    }
}

// MARK: - Navigation Reducer

extension HomeFeature {
    var navigationReducer: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .path(action):
                switch action {
                /// 회원탈퇴 완료 시 Stack 전부 비우기
                case .element(id: _, action: .deleteAccount(.delegate(.completedSignOut))):
                    state.path.removeAll()
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
