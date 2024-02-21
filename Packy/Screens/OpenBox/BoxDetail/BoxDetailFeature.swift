//
//  BoxDetailFeature.swift
//  Packy
//
//  Created Mason Kim on 1/29/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct BoxDetailFeature: Reducer {

    enum PresentingState {
        case detail
        case gift
        case photo
        case letter
    }

    @dynamicMemberLookup
    struct State: Equatable {
        let boxId: Int
        let giftBox: ReceivedGiftBox
        let isToSend: Bool
        @BindingState var presentingState: PresentingState = .detail

        subscript<T>(dynamicMember keyPath: KeyPath<ReceivedGiftBox, T>) -> T {
            giftBox[keyPath: keyPath]
        }
    }

    enum Action: BindableAction {
        // MARK: User Action
        case binding(BindingAction<State>)
        case closeButtonTapped
        case backButtonTapped
        case navigationBarLeadingButtonTapped
        case navigationBarTrailingButtonTapped

        // MARK: Inner Business Action
        case _onTask

        // MARK: Inner SetState Action

        // MARK: Delegate Action
        enum Delegate {
            case closeBoxOpen
            case moveToBoxShare(BoxShareFeature.BoxShareData)
        }
        case delegate(Delegate)
    }

    @Dependency(\.boxClient) var boxClient
    @Dependency(\.dismiss) var dismiss

    var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .navigationBarLeadingButtonTapped:
                return .run { _ in
                    await dismiss()
                }

            case .navigationBarTrailingButtonTapped:
                if state.isToSend {
                    let boxShareData = BoxShareFeature.BoxShareData(
                        senderName: state.senderName,
                        receiverName: state.receiverName,
                        boxName: state.name,
                        boxNormalUrl: state.box.boxNormalUrl,
                        kakaoMessageImgUrl: nil,
                        boxId: state.boxId
                    )
                    return .send(.delegate(.moveToBoxShare(boxShareData)))
                } else {
                    return .send(.delegate(.closeBoxOpen))
                }

            default:
                return .none
            }
        }
    }
}
