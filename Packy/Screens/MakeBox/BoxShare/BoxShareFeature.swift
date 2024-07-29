//
//  BoxShareFeature.swift
//  Packy
//
//  Created Mason Kim on 2/21/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct BoxShareFeature: Reducer {

    struct BoxShareData: Equatable {
        let senderName: String
        let receiverName: String
        let boxName: String
        let boxNormalUrl: String
        var kakaoMessageImgUrl: String?
        let boxId: Int
    }

    @ObservableState
    @dynamicMemberLookup
    struct State: Equatable {
        var data: BoxShareData
        var showCompleteAnimation: Bool
        var didSendToKakao: Bool = false

        init(data: BoxShareData, showCompleteAnimation: Bool) {
            self.data = data
            self.showCompleteAnimation = showCompleteAnimation
        }

        subscript<T>(dynamicMember keyPath: KeyPath<BoxShareData, T>) -> T {
            data[keyPath: keyPath]
        }
    }

    enum Action {
        // MARK: User Action
        case closeButtonTapped
        case sendButtonTapped
        case sendLaterButtonTapped

        // MARK: Inner Business Action
        case onTask

        // MARK: Inner SetState Action
        case setShowCompleteAnimation(Bool)
        case setKakaoImageUrl(String)
        case setDidSendToKakao(Bool)

        // MARK: Delegate Action
        enum Delegate {
            case moveToHome
        }
        case delegate(Delegate)
    }

    @Dependency(\.continuousClock) var clock
    @Dependency(\.kakaoShare) var kakaoShare
    @Dependency(\.boxClient) var boxClient

    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            // MARK: User Action
            case .closeButtonTapped, .sendLaterButtonTapped:
                return .send(.delegate(.moveToHome))

            case .sendButtonTapped:
                guard let kakaoMessage = makeKakaoShareMessage(from: state) else { return .none }
                let boxId = state.boxId

                return .run { send in
                    do {
                        try await kakaoShare.share(kakaoMessage)
                        try await boxClient.changeBoxStatus(boxId, .delivered)
                        await send(.setDidSendToKakao(true))
                    } catch {
                        print("🐛 \(error)")
                    }
                }

            // MARK: Inner Business Action
            case .onTask:
                return .merge(
                    fetchKakaoImage(boxId: state.boxId),
                    showAnimationIfNeeded(showCompleteAnimation: state.showCompleteAnimation)
                )

            // MARK: Inner SetState Action
            case let .setShowCompleteAnimation(showCompleteAnimation):
                state.showCompleteAnimation = showCompleteAnimation
                return .none

            case let .setKakaoImageUrl(imageUrl):
                state.data.kakaoMessageImgUrl = imageUrl
                return .none

            case let .setDidSendToKakao(didSendToKakao):
                state.didSendToKakao = didSendToKakao
                return .none

            case .delegate:
                return .none
            }
        }
    }
}

private extension BoxShareFeature {
    func fetchKakaoImage(boxId: Int) -> Effect<Action> {
        .run { send in
            do {
                let imageUrl = try await boxClient.fetchKakaoImageUrl(boxId)
                await send(.setKakaoImageUrl(imageUrl))
            } catch {
                print("🐛 \(error)")
            }
        }
    }

    func showAnimationIfNeeded(showCompleteAnimation: Bool) -> Effect<Action> {
        guard showCompleteAnimation else { return .none }
        return .run { send in
            try? await clock.sleep(for: .seconds(2.6))
            await send(.setShowCompleteAnimation(false), animation: .spring(duration: 1))
        }
    }

    func makeKakaoShareMessage(from state: State) -> KakaoShareMessage? {
        return KakaoShareMessage(
            sender: state.senderName,
            receiver: state.receiverName,
            imageUrl: state.kakaoMessageImgUrl ?? state.boxNormalUrl, // 카카오 이미지를 불러오는데 실패하면 기본 이미지 삽입
            boxId: "\(state.boxId)"
        )
    }
}
