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

    @ObservableState
    struct State: Equatable {
        var initialImageUrl: String
        var selectedProfile: ProfileImage?
        var profileImages: [ProfileImage] = []

        init(initialImageUrl: String) {
            self.initialImageUrl = initialImageUrl
        }
    }

    enum Action: ViewAction {
        case view(View)

        case setProfileImages([ProfileImage])

        enum View {
            case onTask
            case backButtonTapped
            case confirmButtonTapped
            case selectProfile(ProfileImage)
        }
    }

    @Dependency(\.dismiss) var dismiss
    @Dependency(\.adminClient) var adminClient

    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case let .view(action):
                switch action {
                case .onTask:
                    return fetchProfileImages()

                case .backButtonTapped, .confirmButtonTapped:
                    return .run { _ in
                        await dismiss()
                    }

                case let .selectProfile(profile):
                    state.selectedProfile = profile
                    return .none
                }

            case let .setProfileImages(profileImages):
                state.profileImages = profileImages
                return .none
            }
        }
    }

    private func fetchProfileImages() -> Effect<Action> {
        .run { send in
            do {
                let profileImages = try await adminClient.fetchProfileImages()
                await send(.setProfileImages(profileImages))
            } catch {
                print(error)
            }
        }
    }
}
