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
        var selectedLetterDesign: LetterDesign?
        var letter: String = ""
        var isCompleted: Bool { letter.isEmpty == false }
    }

    @ObservableState
    struct State: Equatable {
        var letterInput: LetterInput = .init()
        var isWriteLetterBottomSheetPresented: Bool = false
        var savedLetter: LetterInput = .init()
        var letterDesigns: [LetterDesign] = []

        var selectedEnvelopeId: Int {
            savedLetter.selectedLetterDesign?.id ?? 0
        }
        var letterContent: String {
            savedLetter.letter
        }

        var showSnackbar: Bool = false
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
    @Dependency(\.adminClient) var adminClient

    // MARK: - Reducer

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding(\.letterInput):
                if state.letterInput.letter.count >= 200 {
                    print("🐛 200자 걸림")
                    state.showSnackbar = true
                }

                return .none

            case .letterInputButtonTapped:
                state.letterInput = state.savedLetter
                // 선택된 편지봉투가 없으면 첫번째 요소를 기본 선택
                if state.letterInput.selectedLetterDesign == nil {
                    state.letterInput.selectedLetterDesign = state.letterDesigns.first
                }
                state.isWriteLetterBottomSheetPresented = true
                return .none

            case .letterSaveButtonTapped:
                state.savedLetter = state.letterInput
                state.isWriteLetterBottomSheetPresented = false
                return .none

            case .WriteLetterBottomSheetCloseButtonTapped:
                guard state.savedLetter != state.letterInput else {
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
                state.isWriteLetterBottomSheetPresented = false
                return .none

            case ._fetchLetterDesigns:
                return fetchLetterDesigns()

            case let ._setLetterDesigns(letterDesigns):
                state.letterDesigns = letterDesigns
                return .none

            default:
                return .none
            }
        }
    }
}

// MARK: - Inner Functions

private extension WriteLetterFeature {
    func fetchLetterDesigns() -> Effect<Action> {
        .run { send in
            do {
                let letterDesigns = try await adminClient.fetchLetterDesigns()
                await send(._setLetterDesigns(letterDesigns))
            } catch {
                print(error)
            }
        }
    }
}
