//
//  BoxStartGuideFeature+Photo.swift
//  Packy
//
//  Created by Mason Kim on 1/27/24.
//

import ComposableArchitecture
import Foundation

@Reducer
struct AddPhotoFeature: Reducer {

    // MARK: - Input

    struct PhotoInput: Equatable {
        var photoUrl: String?
        var text: String = ""

        var isCompleted: Bool { photoUrl != nil }
    }

    struct State: Equatable {
        var isPhotoBottomSheetPresented: Bool = false
        @BindingState var photoInput: PhotoInput = .init()
        var savedPhoto: PhotoInput = .init()
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case photoSelectButtonTapped
        case selectPhoto(Data)
        case photoDeleteButtonTapped
        case photoBottomSheetCloseButtonTapped
        case photoSaveButtonTapped
        case closePhotoSheetAlertConfirmTapped

        case _setUploadedPhotoUrl(String?)
    }

    @Dependency(\.uploadClient) var uploadClient
    @Dependency(\.packyAlert) var packyAlert

    // MARK: - Reducer

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .photoSelectButtonTapped:
                state.isPhotoBottomSheetPresented = true
                state.photoInput = state.savedPhoto
                return .none

            case let .selectPhoto(data):
                return .run { send in
                    let response = try await uploadClient.upload(.init(fileName: "\(UUID()).png", data: data))
                    await send(._setUploadedPhotoUrl(response.uploadedFileUrl))
                }

            case let ._setUploadedPhotoUrl(url):
                state.photoInput.photoUrl = url
                return .none

            case .photoDeleteButtonTapped:
                state.photoInput.photoUrl = nil
                return .none

            case .photoSaveButtonTapped:
                state.savedPhoto = state.photoInput
                state.isPhotoBottomSheetPresented = false
                return .none

            case .photoBottomSheetCloseButtonTapped:
                guard state.savedPhoto.isCompleted == false, state.photoInput.isCompleted else {
                    state.isPhotoBottomSheetPresented = false
                    return .none
                }

                return .run { send in
                    await packyAlert.show(
                        .init(
                            title: "저장하지 않고 나가시겠어요?",
                            description: "입력한 내용이 선물박스에 담기지 않아요",
                            cancel: "취소",
                            confirm: "확인",
                            confirmAction: { await send(.closePhotoSheetAlertConfirmTapped) }
                        )
                    )
                }

            case .closePhotoSheetAlertConfirmTapped:
                state.photoInput = .init()
                state.isPhotoBottomSheetPresented = false
                return .none
            }
        }
    }
}
