//
//  DeleteAccountFeature.swift
//  Packy
//
//  Created Mason Kim on 2/4/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct DeleteAccountFeature: Reducer {

    enum ShowingState {
        case signOut
        case completed
    }

    struct State: Equatable {
        var showingState: ShowingState = .signOut
    }

    enum Action {
        // MARK: User Action
        case backButtonTapped
        case signOutButtonTapped
        case signOutConfirmButtonTapped
        case completedConfirmButtonTapped

        // MARK: Inner Business Action
        case _onTask

        // MARK: Inner SetState Action

        // MARK: Child Action
        enum Delegate {
            case completedSignOut
        }
        case delegate(Delegate)
    }

    @Dependency(\.dismiss) var dismiss
    @Dependency(\.packyAlert) var packyAlert

    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case ._onTask:
                return .none

            case .backButtonTapped:
                return .run { _ in await dismiss() }

            case .signOutButtonTapped:
                return .run { send in
                    await packyAlert.show(.init(title: "패키 서비스를 탈퇴하시겠어요?", cancel: "취소", confirm: "확인", cancelAction: {
                        await dismiss()
                    }, confirmAction: {
                        await send(.signOutConfirmButtonTapped)
                    }))
                }

            case .signOutConfirmButtonTapped:
                // TODO: 실제 회원탈퇴 로직 수행 후...
                state.showingState = .completed
                return .none

            case .completedConfirmButtonTapped:
                return .none

            default:
                return .none
            }
        }
    }
}
