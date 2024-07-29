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

    @ObservableState
    struct State: Equatable {
        var settingMenus: [SettingMenu] = []
        var profile: Profile?

        @Presents var editProfile: EditProfileFeature.State?
    }

    enum Action: ViewAction {
        case view(View)
        case delegate(Delegate)

        case setSettingMenus([SettingMenu])
        case setProfile(Profile)

        // MARK: Child Action
        case editProfile(PresentationAction<EditProfileFeature.Action>)

        enum View {
            case onTask
            case backButtonTapped
            case logoutButtonTapped
            case logoutConfirmButtonTapped
            case editProfileButtonTapped
        }

        enum Delegate {
            case completeSignOut
        }
    }

    @Dependency(\.dismiss) var dismiss
    @Dependency(\.packyAlert) var packyAlert
    @Dependency(\.keychain) var keychain
    @Dependency(\.authClient) var authClient

    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case let .view(action):
                switch action {
                case .onTask:
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
                                    await send(.view(.logoutConfirmButtonTapped))
                                }
                            )
                        )
                    }

                case .logoutConfirmButtonTapped:
                    keychain.delete(.accessToken)
                    keychain.delete(.refreshToken)
                    return .send(.delegate(.completeSignOut))

                case .backButtonTapped:
                    return .run { _ in await dismiss() }
                }

            case let .setSettingMenus(menus):
                state.settingMenus = menus
                return .none

            case let .setProfile(profile):
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
                await send(.setSettingMenus(settingMenus))
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
                await send(.setProfile(profile))
            } catch {
                print("🐛 \(error)")
            }
        }
    }
}
