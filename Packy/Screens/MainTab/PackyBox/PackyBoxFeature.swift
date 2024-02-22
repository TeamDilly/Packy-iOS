//
//  PackyBoxFeature.swift
//  Packy
//
//  Created Mason Kim on 2/22/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct PackyBoxFeature: Reducer {

    struct State: Equatable {
        /// 패키가 준비한 선물박스
        var packyBox: ReceivedGiftBox?
    }

    enum Action {
        // MARK: Inner Business Action
        case _fetchPackyBox

        // MARK: Inner SetState Action
        case _setPackyBox(ReceivedGiftBox?)
    }

    @Dependency(\.adminClient) var adminClient

    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            // MARK: User Action

            // MARK: Inner Business Action
            case ._fetchPackyBox:
                return fetchPackyBox()

            // MARK: Inner SetState Action
            case let ._setPackyBox(packyBox):
                state.packyBox = packyBox
                return .none

            }
        }
    }
}

private extension PackyBoxFeature {
    func fetchPackyBox() -> Effect<Action> {
        .run { send in
            do {
                // TODO: 수정
                let packyBox = try await adminClient.fetchPackyGiftBox(.onboarding)
                await send(._setPackyBox(packyBox))
                // await send(._setPackyBox(.mock))
            } catch {
                print("🐛 \(error)")
            }
        }
    }
}
