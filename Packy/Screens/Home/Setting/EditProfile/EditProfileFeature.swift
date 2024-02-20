//
//  EditProfileFeature.swift
//  Packy
//
//  Created Mason Kim on 2/19/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct EditProfileFeature: Reducer {

    struct State: Equatable {
        let fetchedProfile: Profile

        @BindingState var nickname: String
        var selectedProfile: ProfileImage?

        @PresentationState var editSelectProfile: EditSelectProfileFeature.State?

        var hasProfileChanges: Bool {
            fetchedProfile.nickname != nickname ||
            selectedProfile?.imageUrl != fetchedProfile.imageUrl
        }

        init(fetchedProfile: Profile) {
            self.fetchedProfile = fetchedProfile
            self.nickname = fetchedProfile.nickname
        }
    }

    enum Action: BindableAction {
        // MARK: User Action
        case binding(BindingAction<State>)
        case backButtonTapped
        case saveButtonTapped
        case profileButtonTapped

        // MARK: Inner Business Action
        case _onTask

        // MARK: Child Action
        case editSelectProfile(PresentationAction<EditSelectProfileFeature.Action>)

        // MARK: Delegate Action
        enum Delegate {
            case didUpdateProfile(Profile)
        }
        case delegate(Delegate)
    }

    @Dependency(\.dismiss) var dismiss
    @Dependency(\.authClient) var authClient

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce<State, Action> { state, action in
            switch action {
            case .backButtonTapped:
                return .run { _ in
                    await dismiss()
                }

            case .saveButtonTapped:
                guard state.hasProfileChanges else {
                    return .run { _ in await dismiss() }
                }
                return updateProfile(state: state)


            case .profileButtonTapped:
                state.editSelectProfile = .init(initialImageUrl: state.fetchedProfile.imageUrl)
                return .none

            case .editSelectProfile(.presented(.confirmButtonTapped)):
                guard let selectedProfile = state.editSelectProfile?.selectedProfile else { return .none }
                state.selectedProfile = selectedProfile
                return .none

            default:
                return .none
            }
        }
        .ifLet(\.$editSelectProfile, action: /Action.editSelectProfile) {
            EditSelectProfileFeature()
        }
    }
}

private extension EditProfileFeature {
    func updateProfile(state: State) -> Effect<Action> {
        // 변경이 있는 항목만 업데이트 요청
        let updatedNickname = state.fetchedProfile.nickname != state.nickname ? state.nickname : nil
        let updatedProfileId = state.selectedProfile?.id
        let request = ProfileRequest(nickname: updatedNickname, profileImageId: updatedProfileId)

        return .run { send in
            let fetchedProfile = try await authClient.updateProfile(request)
            await send(.delegate(.didUpdateProfile(fetchedProfile)))
            await dismiss()
        }
    }
}
