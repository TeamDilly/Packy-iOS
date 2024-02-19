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
        @BindingState var nickname: String
        var imageUrl: String

        @PresentationState var editSelectProfile: EditSelectProfileFeature.State?
    }

    enum Action: BindableAction {
        // MARK: User Action
        case binding(BindingAction<State>)
        case backButtonTapped
        case saveButtonTapped
        case profileButtonTapped

        // MARK: Inner Business Action
        case _onTask

        // MARK: Inner SetState Action

        // MARK: Child Action
        case editSelectProfile(PresentationAction<EditSelectProfileFeature.Action>)
    }

    @Dependency(\.dismiss) var dismiss

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce<State, Action> { state, action in
            switch action {
            case .backButtonTapped:
                return .run { _ in
                    await dismiss()
                }

            case .saveButtonTapped:
                return .none

            case .profileButtonTapped:
                state.editSelectProfile = .init(selectedImageUrl: state.imageUrl)
                return .none

            case .editSelectProfile(.presented(.confirmButtonTapped)):
                guard let selectedImageUrl = state.editSelectProfile?.selectedImageUrl else { print("nonono"); return .none }
                state.imageUrl = selectedImageUrl
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
