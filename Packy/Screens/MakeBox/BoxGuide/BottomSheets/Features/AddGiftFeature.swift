//
//  AddGiftFeature.swift
//  Packy
//
//  Created by Mason Kim on 1/27/24.
//

import ComposableArchitecture
import Foundation

@Reducer
struct AddGiftFeature: Reducer {

    struct GiftInput: Equatable {
        var imageUrl: URL?
        var isCompleted: Bool { imageUrl != nil }
    }

    struct State: Equatable {
        var isAddGiftBottomSheetPresented: Bool = false
        var giftInput: GiftInput = .init()
        var savedGift: GiftInput = .init()
    }

    enum Action {
        case addGiftButtonTapped
        case selectGiftImage(Data)
        case deleteGiftImageButtonTapped
        case notSelectGiftButtonTapped
        case addGiftSheetCloseButtonTapped
        case closeGiftSheetAlertConfirmTapped
        case giftSaveButtonTapped

        case _setUploadedGiftUrl(URL?)
    }

    @Dependency(\.continuousClock) var clock
    @Dependency(\.packyAlert) var packyAlert
    @Dependency(\.uploadClient) var uploadClient

    // MARK: - Reducer

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            
            case .addGiftButtonTapped:
                state.giftInput = state.savedGift
                state.isAddGiftBottomSheetPresented = true
                return .none

            case let .selectGiftImage(data):
                return .run { send in
                    let response = try await uploadClient.upload(.init(fileName: "\(UUID()).png", data: data))
                    await send(._setUploadedGiftUrl(URL(string: response.uploadedFileUrl)))
                }

            case let ._setUploadedGiftUrl(url):
                state.giftInput.imageUrl = url
                return .none

            case .deleteGiftImageButtonTapped:
                state.giftInput.imageUrl = nil
                return .none

            case .giftSaveButtonTapped:
                state.savedGift = state.giftInput
                state.isAddGiftBottomSheetPresented = false
                return .none

            case .notSelectGiftButtonTapped:
                state.savedGift = .init()
                state.isAddGiftBottomSheetPresented = false
                return .none

            case .closeGiftSheetAlertConfirmTapped:
                state.giftInput = .init()
                state.isAddGiftBottomSheetPresented = false
                return .none

            case .addGiftSheetCloseButtonTapped:
                guard state.savedGift.isCompleted == false, state.giftInput.isCompleted else {
                    state.isAddGiftBottomSheetPresented = false
                    return .none
                }

                return .run { send in
                    await packyAlert.show(
                        .init(
                            title: "저장하지 않고 나가시겠어요?",
                            description: "입력한 내용이 선물박스에 담기지 않아요",
                            cancel: "취소",
                            confirm: "확인",
                            confirmAction: {
                                await send(.closeGiftSheetAlertConfirmTapped)
                            }
                        )
                    )
                }

            default:
                return .none
            }
        }
    }
}
