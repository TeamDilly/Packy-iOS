//
//  SignUpProfileFeature.swift
//  Packy
//
//  Created Mason Kim on 1/9/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct SignUpProfileFeature: Reducer {

    @ObservableState
    struct State: Equatable {
        let socialLoginInfo: SocialLoginInfo
        let nickName: String

        var selectedProfileImage: ProfileImage?
        var profileImages: [ProfileImage] = []
    }

    enum Action {
        // MARK: User Action
        case backButtonTapped
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

            case .backButtonTapped:
                return .run { _ in await dismiss() }

            case let .selectProfile(profileImage):
                state.selectedProfileImage = profileImage
                return .none

            case let ._setProfileImages(profileImages):
                state.profileImages = profileImages
                state.selectedProfileImage = profileImages.first
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
