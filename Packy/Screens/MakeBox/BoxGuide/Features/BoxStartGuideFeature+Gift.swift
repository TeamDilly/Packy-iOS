//
//  BoxStartGuideFeature+Gift.swift
//  Packy
//
//  Created by Mason Kim on 1/27/24.
//

import ComposableArchitecture
import Foundation

extension BoxStartGuideFeature {

    // MARK: - Input

    struct GiftInput: Equatable {
        var imageUrl: URL?
        var isCompleted: Bool { imageUrl != nil }
    }

    // MARK: - Reducer

    var giftReducer: some Reducer<State, Action> {
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
                        .init(title: "선물탭을 진짜 닫겠는가", description: "진짜루?", cancel: "놉,,", confirm: "예쓰", confirmAction: {
                            await send(.closeGiftSheetAlertConfirmTapped)
                        })
                    )
                }

            default:
                return .none
            }
        }
    }
}
