//
//  HomeFeature.swift
//  Packy
//
//  Created Mason Kim on 2/4/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct HomeFeature: Reducer {

    struct State: Equatable {
        var path: StackState<HomeNavigationPath.State> = .init()
        var profile: Profile?
    }

    enum Action {
        // MARK: User Action

        // MARK: Inner Business Action
        case _onTask

        // MARK: Inner SetState Action
        case _setProfile(Profile)

        // MARK: Child Action
        case path(StackAction<HomeNavigationPath.State, HomeNavigationPath.Action>)
    }

    @Dependency(\.authClient) var authClient

    var body: some Reducer<State, Action> {
        navigationReducer

        Reduce<State, Action> { state, action in
            switch action {
            case ._onTask:
                guard state.profile == nil else { return .none }
                return fetchProfile()

            case let ._setProfile(profile):
                state.profile = profile
                return .none

            case .path:
                return .none
            }
        }
    }
}

private extension HomeFeature {
    func fetchProfile() -> Effect<Action> {
        .run { send in
            do {
                let profile = try await authClient.fetchProfile()
                await send(._setProfile(profile))
            } catch {
                print("🐛 \(error)")
            }
        }
    }
}
