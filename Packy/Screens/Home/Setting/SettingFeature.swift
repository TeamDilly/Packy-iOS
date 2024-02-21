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
        var profile: Profile?

        @PresentationState var editProfile: EditProfileFeature.State?
    }

    enum Action {
        // MARK: User Action
        case backButtonTapped
        case logoutButtonTapped
        case logoutConfirmButtonTapped
        case editProfileButtonTapped

        // MARK: Inner Business Action
        case _onTask

        // MARK: Inner SetState Action
        case _setSettingMenus([SettingMenu])
        case _setProfile(Profile)

        // MARK: Child Action
        case editProfile(PresentationAction<EditProfileFeature.Action>)

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
                return .merge(
                    fetchProfileIfNeeded(state.profile),
                    fetchSettingMenus()
                )

            case .editProfileButtonTapped:
                guard let profile = state.profile else { return .none }
                state.editProfile = .init(fetchedProfile: profile)
                return .none

            case .logoutButtonTapped:
                return .run { send in
                    await packyAlert.show(
                        .init(
                            title: "로그아웃 하시겠어요?",
                            cancel: "취소",
                            confirm: "로그아웃",
                            confirmAction: {
                                await send(.logoutConfirmButtonTapped) }
                        )
                    )
                }

            case .logoutConfirmButtonTapped:
                keychain.delete(.accessToken)
                keychain.delete(.refreshToken)
                return .send(.delegate(.completeSignOut))

            case .backButtonTapped:
                return .run { _ in await dismiss() }

            case let ._setSettingMenus(menus):
                state.settingMenus = menus
                return .none

            case let ._setProfile(profile):
                state.profile = profile
                return .none

            case .editProfile(.presented(.delegate(.didUpdateProfile(let profile)))):
                state.profile = profile
                return .none

            default:
                return .none
            }
        }
        .ifLet(\.$editProfile, action: \.editProfile) {
            EditProfileFeature()
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

    func fetchProfileIfNeeded(_ profile: Profile?) -> Effect<Action> {
        guard profile == nil else { return .none }

        return .run { send in
            do {
                let profile = try await authClient.fetchProfile()
                await send(._setProfile(profile))
            } catch {
                print("🐛 \(error)")
            }
        }
    }
}
