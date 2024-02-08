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
        var giftBoxes: [SentReceivedGiftBox] = []
    }

    enum Action {
        // MARK: User Action

        // MARK: Inner Business Action
        case _onTask

        // MARK: Inner SetState Action
        case _setProfile(Profile)
        case _setGiftBoxes([SentReceivedGiftBox])

        // MARK: Child Action
        case path(StackAction<HomeNavigationPath.State, HomeNavigationPath.Action>)
    }

    @Dependency(\.authClient) var authClient
    @Dependency(\.boxClient) var boxClient

    var body: some Reducer<State, Action> {
        navigationReducer

        Reduce<State, Action> { state, action in
            switch action {
            case ._onTask:
                return .merge(
                    fetchProfileIfNeeded(state: state),
                    fetchGiftBoxes()
                )

            case let ._setProfile(profile):
                state.profile = profile
                return .none

            case let ._setGiftBoxes(giftBoxes):
                state.giftBoxes = giftBoxes
                return .none

            case .path:
                return .none
            }
        }
    }
}

private extension HomeFeature {
    func fetchProfileIfNeeded(state: State) -> Effect<Action> {
        guard state.profile == nil else { return .none }

        return .run { send in
            do {
                let profile = try await authClient.fetchProfile()
                await send(._setProfile(profile))
            } catch {
                print("🐛 \(error)")
            }
        }
    }

    func fetchGiftBoxes() -> Effect<Action> {
        .run { send in
            do {
                let giftBoxesData = try await boxClient.fetchGiftBoxes(.init())
                await send(._setGiftBoxes(giftBoxesData.giftBoxes))
            } catch {
                print("🐛 \(error)")
            }
        }
    }
}
