//
//  EditSelectProfileFeature.swift
//  Packy
//
//  Created Mason Kim on 2/19/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct EditSelectProfileFeature: Reducer {

    struct State: Equatable {
        var initialImageUrl: String
        var selectedProfile: ProfileImage?
        var profileImages: [ProfileImage] = []
    }

    enum Action {
        // MARK: User Action
        case backButtonTapped
        case confirmButtonTapped
        case selectProfile(ProfileImage)

        // MARK: Inner Business Action
        case _onTask

        // MARK: Inner SetState Action
        case _setProfileImages([ProfileImage])
    }

    @Dependency(\.dismiss) var dismiss
    @Dependency(\.adminClient) var adminClient

    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case ._onTask:
                return fetchProfileImages()

            case .backButtonTapped, .confirmButtonTapped:
                return .run { _ in
                    await dismiss()
                }

            case let .selectProfile(profile):
                state.selectedProfile = profile
                return .none

            case let ._setProfileImages(profileImages):
                state.profileImages = profileImages
                return .none
            }
        }
    }

    private func fetchProfileImages() -> Effect<Action> {
        .run { send in
            do {
                let profileImages = try await adminClient.fetchProfileImages()
                await send(._setProfileImages(profileImages))
            } catch {
                print(error)
            }
        }
    }
}
