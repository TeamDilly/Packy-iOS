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

    struct State: Equatable {
        let socialLoginInfo: SocialLoginInfo
        let nickName: String

        @BindingState var textInput: String = ""
        var selectedProfileImage: ProfileImage?
        var profileImages: [ProfileImage] = []
    }

    enum Action: BindableAction {
        // MARK: User Action
        case binding(BindingAction<State>)
        case backButtonTapped
        case selectProfile(ProfileImage)

        // MARK: Inner Business Action
        case _onTask

        // MARK: Inner SetState Action
        case _setProfileImages([ProfileImage])

        // MARK: Child Action
    }

    @Dependency(\.dismiss) var dismiss
    @Dependency(\.designClient) var designClient

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce<State, Action> { state, action in
            switch action {
            case ._onTask:
                return fetchProfileImages()

            case .binding:
                return .none

            case .backButtonTapped:
                return .run { _ in await dismiss() }

            case let .selectProfile(profileImage):
                state.selectedProfileImage = profileImage
                return .none

            case let ._setProfileImages(profileImages):
                state.profileImages = profileImages
                state.selectedProfileImage = profileImages.first
                print("✅ selected: \(state.selectedProfileImage?.id)")
                return .none
            }
        }
    }

    private func fetchProfileImages() -> Effect<Action> {
        .run { send in
            do {
                let profileImages = try await designClient.fetchProfileImages()
                await send(._setProfileImages(profileImages))
            } catch {
                print(error)
            }
        }
    }
}
