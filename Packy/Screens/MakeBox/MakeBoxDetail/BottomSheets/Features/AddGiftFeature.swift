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
        var photoData: PhotoData?
        var isCompleted: Bool { photoData != nil }
    }

    @ObservableState
    struct State: Equatable {
        var isAddGiftBottomSheetPresented: Bool = false
        var giftInput: GiftInput = .init()
        var savedGift: GiftInput = .init()
    }

    enum Action {
        case addGiftButtonTapped
        case selectGiftImage(PhotoData)
        case deleteGiftImageButtonTapped
        case notSelectGiftButtonTapped
        case addGiftSheetCloseButtonTapped
        case closeGiftSheetAlertConfirmTapped
        case giftSaveButtonTapped
    }

    @Dependency(\.continuousClock) var clock
    @Dependency(\.packyAlert) var packyAlert

    // MARK: - Reducer

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            
            case .addGiftButtonTapped:
                state.giftInput = state.savedGift
                state.isAddGiftBottomSheetPresented = true
                return .none

            case let .selectGiftImage(data):
                state.giftInput.photoData = data
                return .none

            case .deleteGiftImageButtonTapped:
                state.giftInput.photoData = nil
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
                guard state.savedGift != state.giftInput else {
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
