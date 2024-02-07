//
//  BoxStartGuideFeature+Letter.swift
//  Packy
//
//  Created by Mason Kim on 1/27/24.
//

import ComposableArchitecture
import Foundation

extension BoxStartGuideFeature {

    // MARK: - Input

    struct LetterInput: Equatable {
        @BindingState var selectedLetterDesign: LetterDesign?
        var letter: String = ""
        var isCompleted: Bool { letter.isEmpty == false }
    }

    // MARK: - Reducer

    var letterReducer: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {

            case .letterInputButtonTapped:
                state.letterInput = state.savedLetter
                state.isLetterBottomSheetPresented = true
                return .none

            case .letterSaveButtonTapped:
                state.savedLetter = state.letterInput
                state.isLetterBottomSheetPresented = false
                return .none

            case .letterBottomSheetCloseButtonTapped:
                guard state.savedLetter.isCompleted == false, state.letterInput.isCompleted else {
                    state.isLetterBottomSheetPresented = false
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
                                await send(.closeLetterSheetAlertConfirmTapped)
                            }
                        )
                    )
                }

            case .closeLetterSheetAlertConfirmTapped:
                state.letterInput = .init()
                state.letterInput.selectedLetterDesign = state.letterDesigns.first
                state.isLetterBottomSheetPresented = false
                return .none

            default:
                return .none
            }
        }
    }
}
