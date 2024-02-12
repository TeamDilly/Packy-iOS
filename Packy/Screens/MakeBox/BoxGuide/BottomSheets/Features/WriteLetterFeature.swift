//
//  WriteLetterFeature.swift
//  Packy
//
//  Created by Mason Kim on 1/27/24.
//

import ComposableArchitecture
import Foundation

@Reducer
struct WriteLetterFeature: Reducer {

    struct LetterInput: Equatable {
        @BindingState var selectedLetterDesign: LetterDesign?
        var letter: String = ""
        var isCompleted: Bool { letter.isEmpty == false }
    }

    struct State: Equatable {
        @BindingState var letterInput: LetterInput = .init()
        var isWriteLetterBottomSheetPresented: Bool = false
        var savedLetter: LetterInput = .init()
        var letterDesigns: [LetterDesign] = []

        var selectedEnvelopeId: Int {
            savedLetter.selectedLetterDesign?.id ?? 0
        }
        var letterContent: String {
            savedLetter.letter
        }
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)

        case letterInputButtonTapped
        case letterSaveButtonTapped
        case WriteLetterBottomSheetCloseButtonTapped
        case closeLetterSheetAlertConfirmTapped

        case _fetchLetterDesigns
        case _setLetterDesigns([LetterDesign])
    }

    @Dependency(\.packyAlert) var packyAlert
    @Dependency(\.designClient) var designClient

    // MARK: - Reducer

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {

            case .letterInputButtonTapped:
                state.letterInput = state.savedLetter
                state.isWriteLetterBottomSheetPresented = true
                return .none

            case .letterSaveButtonTapped:
                state.savedLetter = state.letterInput
                state.isWriteLetterBottomSheetPresented = false
                return .none

            case .WriteLetterBottomSheetCloseButtonTapped:
                guard state.savedLetter.isCompleted == false, state.letterInput.isCompleted else {
                    state.isWriteLetterBottomSheetPresented = false
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
                // state.letterInput.selectedLetterDesign = state.letterDesigns.first
                state.isWriteLetterBottomSheetPresented = false
                return .none

            case ._fetchLetterDesigns:
                return fetchLetterDesigns()

            case let ._setLetterDesigns(letterDesigns):
                state.letterDesigns = letterDesigns
                state.letterInput.selectedLetterDesign = letterDesigns.first
                return .none

            default:
                return .none
            }
        }
    }

    private func fetchLetterDesigns() -> Effect<Action> {
        .run { send in
            do {
                let letterDesigns = try await designClient.fetchLetterDesigns()
                await send(._setLetterDesigns(letterDesigns))
            } catch {
                print(error)
            }
        }
    }
}
