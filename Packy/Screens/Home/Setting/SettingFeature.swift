//
//  SettingFeature.swift
//  Packy
//
//  Created Mason Kim on 2/4/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct SettingFeature: Reducer {

    struct State: Equatable {
        var settingMenus: [SettingMenu] = []
    }

    enum Action {
        // MARK: User Action
        case backButtonTapped
        case logoutButtonTapped
        case logoutConfirmButtonTapped

        // MARK: Inner Business Action
        case _onTask

        // MARK: Inner SetState Action
        case _setSettingMenus([SettingMenu])

        // MARK: Delegate Action
        enum Delegate {
            case completeSignOut
        }
        case delegate(Delegate)
    }

    @Dependency(\.dismiss) var dismiss
    @Dependency(\.packyAlert) var packyAlert
    @Dependency(\.keychain) var keychain
    @Dependency(\.authClient) var authClient

    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case ._onTask:
                return fetchSettingMenus()

            case .logoutButtonTapped:
                return .run { send in
                    await packyAlert.show(.init(title: "로그아웃 하시겠어요?", cancel: "취소", confirm: "로그아웃", confirmAction: {
                        await send(.logoutConfirmButtonTapped)
                    }))
                }

            case .logoutConfirmButtonTapped:
                keychain.delete(.accessToken)
                keychain.delete(.refreshToken)
                return .send(.delegate(.completeSignOut))

            case .backButtonTapped:
                return .run { _ in await dismiss() }

            default:
                return .none
            }
        }
    }
}

private extension SettingFeature {
    func fetchSettingMenus() -> Effect<Action> {
        .run { send in
            do {
                let settingMenus = try await authClient.fetchSettingMenus()
                await send(._setSettingMenus(settingMenus))
            } catch {
                print("🐛 \(error)")
            }
        }
    }
}
