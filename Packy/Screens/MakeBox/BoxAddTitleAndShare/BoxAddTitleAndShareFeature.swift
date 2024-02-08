//
//  BoxAddTitleAndShareFeature.swift
//  Packy
//
//  Created Mason Kim on 1/27/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct BoxAddTitleAndShareFeature: Reducer {

    enum ShowingState {
        case addTitle
        case completed
        case send
    }

    struct State: Equatable {
        var giftBox: SendingGiftBox
        let boxDesign: BoxDesign
        @BindingState var boxNameInput: String = ""
        @BindingState var showingState: ShowingState = .addTitle
    }

    enum Action: BindableAction {
        // MARK: User Action
        case binding(BindingAction<State>)
        case backButtonTapped
        case closeButtonTapped
        case nextButtonTapped
        case sendButtonTapped

        // MARK: Inner Business Action
        case _onTask

        // MARK: Inner SetState Action
        case _setBoxId(Int)

        // MARK: Delegate Action
        enum Delegate {
            case moveToHome
            case moveTo
        }
        case delegate(Delegate)
    }

    @Dependency(\.continuousClock) var clock
    @Dependency(\.boxClient) var boxClient
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.kakaoShare) var kakaoShare

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce<State, Action> { state, action in
            switch action {
            case .binding:
                return .none

            case .backButtonTapped:
                return .run { _ in await dismiss() }

            case .closeButtonTapped:
                return .send(.delegate(.moveToHome))

            case .nextButtonTapped:
                state.giftBox.name = state.boxNameInput
                return .concatenate(
                    // 저장
                    saveGiftBox(state.giftBox),

                    // 이후 화면 전환
                    .run { send in
                        await send(.binding(.set(\.$showingState, .completed)), animation: .spring)
                        try? await clock.sleep(for: .seconds(2.6))
                        await send(.binding(.set(\.$showingState, .send)), animation: .spring(duration: 1))
                    }
                )

            case .sendButtonTapped:
                let kakaoMessage = makeKakaoShareMessage(from: state)

                return .run { send in
                    try await kakaoShare.share(kakaoMessage)
                }

            case let ._setBoxId(boxId):
                state.giftBox.boxId = boxId
                return .none

            case ._onTask:
                return .none

            default:
                return .none
            }
        }
    }
}


// MARK: - Inner Functions

private extension BoxAddTitleAndShareFeature {
    func saveGiftBox(_ giftBox: SendingGiftBox) -> Effect<Action> {
        return .run { send in
            do {
                let response = try await boxClient.makeGiftBox(giftBox)
                await send(._setBoxId(response.id))
            } catch {
                print(error)
            }
        }
    }

    func makeKakaoShareMessage(from state: State) -> KakaoShareMessage {
        let sender = state.giftBox.senderName
        let receiver = state.giftBox.receiverName
        let imageUrl = state.boxDesign.boxSetUrl
        let boxId = state.giftBox.boxId

        return KakaoShareMessage(sender: sender, receiver: receiver, imageUrl: imageUrl, boxId: "\(boxId ?? -1)")
    }
}
