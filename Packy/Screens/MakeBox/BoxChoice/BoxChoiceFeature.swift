//
//  BoxChoiceFeature.swift
//  Packy
//
//  Created Mason Kim on 1/14/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct BoxChoiceFeature: Reducer {

    struct PassingData {
        let senderInfo: BoxSenderInfo
        let selectedBox: BoxDesign?
        let boxDesigns: [BoxDesign]
    }

    struct State: Equatable {
        let senderInfo: BoxSenderInfo
        var selectedBox: BoxDesign?
        @BindingState var selectedMessage: Int = 0
        var isPresentingFinishedMotionView: Bool = false

        var boxDesigns: [BoxDesign] = []

        var passingData: PassingData {
            .init(
                senderInfo: senderInfo,
                selectedBox: selectedBox,
                boxDesigns: boxDesigns
            )
        }
    }

    enum Action: BindableAction {
        // MARK: User Action
        case binding(BindingAction<State>)
        case selectBox(BoxDesign)
        case backButtonTapped
        case nextButtonTapped
        case closeButtonTapped

        // MARK: Inner Business Action
        case _onTask

        // MARK: Inner SetState Action
        case _setIsPresentingFinishedMotionView(Bool)
        case _setBoxDesigns([BoxDesign])

        // MARK: Delegate Action
        enum Delegate {
            case moveToBoxStartGuide(PassingData)
        }
        case delegate(Delegate)
    }

    @Dependency(\.continuousClock) var clock
    @Dependency(\.userDefaults) var userDefaults
    @Dependency(\.designClient) var designClient
    @Dependency(\.packyAlert) var packyAlert
    @Dependency(\.dismiss) var dismiss

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce<State, Action> { state, action in
            switch action {
            case .binding:
                return .none

            case ._onTask:
                return .run { send in
                    do {
                        let boxDesigns = try await designClient.fetchBoxDesigns()
                        await send(._setBoxDesigns(boxDesigns), animation: .spring)
                        if let firstBox = boxDesigns.first {
                            await send(.selectBox(firstBox), animation: .spring)
                        }
                    } catch {
                        print(error)
                    }
                }

            case let .selectBox(id):
                state.selectedBox = id
                return .none

            case .backButtonTapped:
                return .run { _ in await dismiss() }

            case .nextButtonTapped:
                // 이미 사용자가 BoxGuide 에 진입했던 경우에는, BoxMotion 을 나타내지 않음
                guard userDefaults.boolForKey(.didEnteredBoxGuide) else {
                    return .send(.delegate(.moveToBoxStartGuide(state.passingData)))
                }
                return showBoxMotion(state.passingData)

            case .closeButtonTapped:
                // state.isShowAlert = true
                return .run { send in
                    await packyAlert.show(
                        .init(
                            title: "title",
                            confirm: "confirm",
                            confirmAction: {
                                // TODO: 로직 구현?
                                // await send(.closeButtonTapped)
                            }
                        )
                    )
                }

            // case .alertConfirmButtonTapped:
            //     return .none

            case let ._setIsPresentingFinishedMotionView(isPresented):
                state.isPresentingFinishedMotionView = isPresented
                return .none

            case let ._setBoxDesigns(boxDesigns):
                state.boxDesigns = boxDesigns
                return .none

            case .delegate:
                return .none
            }
        }
    }
}

// MARK: - Inner Functions

private extension BoxChoiceFeature {
    func showBoxMotion(_ passingData: PassingData) -> Effect<Action> {
        .run { send in
            await send(._setIsPresentingFinishedMotionView(true))
            try? await clock.sleep(for: .seconds(Constants.boxAnimationDuration))

            await send(.delegate(.moveToBoxStartGuide(passingData)))

            try? await clock.sleep(for: .seconds(0.1))
            await send(._setIsPresentingFinishedMotionView(false))
        }
    }
}
