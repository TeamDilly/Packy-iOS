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

    @ObservableState
    struct State: Equatable {
        var showingState: ShowingState = .signOut
    }

    enum Action: ViewAction {
        case view(View)
        case delegate(Delegate)

        case setShowingState(ShowingState)

        enum View {
            case onTask
            case backButtonTapped
            case signOutButtonTapped
            case signOutConfirmButtonTapped
            case completedConfirmButtonTapped
        }

        enum Delegate {
            case completedSignOut
        }
    }

    @Dependency(\.dismiss) var dismiss
    @Dependency(\.packyAlert) var packyAlert
    @Dependency(\.keychain) var keychain
    @Dependency(\.authClient) var authClient

    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case let .view(action):
                switch action {
                case .onTask:
                    return .none
                    
                case .backButtonTapped:
                    return .run { _ in await dismiss() }
                    
                case .signOutButtonTapped:
                    return .run { send in
                        await packyAlert.show(
                            .init(
                                title: "패키 서비스를 탈퇴하시겠어요?",
                                cancel: "취소",
                                confirm: "확인",
                                cancelAction: { await dismiss() },
                                confirmAction: { await send(.view(.signOutConfirmButtonTapped)) }
                            )
                        )
                    }
                    
                case .signOutConfirmButtonTapped:
                    return .run { send in
                        do {
                            _ = try await authClient.withdraw()
                            
                            keychain.delete(.accessToken)
                            keychain.delete(.refreshToken)
                            
                            await send(.setShowingState(.completed), animation: .spring)
                        } catch {
                            print("🐛 \(error)")
                        }
                    }
                    
                case .completedConfirmButtonTapped:
                    return .run { send in
                        await send(.delegate(.completedSignOut), animation: .spring)
                    }
                }

            case let .setShowingState(showingState):
                state.showingState = showingState
                return .none

            default:
                return .none
            }
        }
    }
}
