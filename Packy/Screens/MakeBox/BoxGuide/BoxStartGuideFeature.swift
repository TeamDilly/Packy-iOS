//
//  BoxStartGuideFeature.swift
//  Packy
//
//  Created Mason Kim on 1/13/24.
//

import Foundation
import ComposableArchitecture
import YouTubePlayerKit
import SwiftUI

@Reducer
struct BoxStartGuideFeature: Reducer {

    struct PhotoInput: Identifiable, Hashable {
        let id: Int
        var photoUrl: URL?
        @BindingState var text: String = ""
    }

    struct State: Equatable {
        let senderInfo: BoxSenderInfo
        let selectedBoxIndex: Int

        @BindingState var isMusicBottomSheetPresented: Bool = false
        @BindingState var isLetterBottomSheetPresented: Bool = false
        @BindingState var isPhotoBottomSheetPresented: Bool = false
        @BindingState var isGiftBottomSheetPresented: Bool = false

        @BindingState var musicLinkUrlInput: String = "https://www.youtube.com/watch?v=OZRLiBSeAG8"
        var musicBottomSheetMode: MusicBottomSheetMode = .choice
        var selectedMusicUrl: YouTubePlayer?
        @BindingState var selectedMusicIndex: Int = 0
        var showInvalidMusicUrlError: Bool = false
        var musicSheetDetents: Set<PresentationDetent> = MusicBottomSheetMode.allDetents

        @BindingState var photoInput: PhotoInput = .init(id: 0)

        @PresentationState var boxFinishAlert: AlertState<Action.Alert>?
    }

    enum Action: BindableAction {
        // MARK: User Action
        case binding(BindingAction<State>)
        case musicBottomSheetBackButtonTapped
        case musicChoiceUserSelectButtonTapped
        case musicChoiceRecommendButtonTapped
        case musicLinkConfirmButtonTapped
        case musicLinkSaveButtonTapped
        case musicLinkDeleteButtonTapped

        case photoAddButtonTapped
        case photoSaveButtonTapped
        case photoDeleteButtonTapped

        case nextButtonTapped

        // MARK: Inner Business Action
        case _onTask

        // MARK: Inner SetState Action
        case _setDetents(Set<PresentationDetent>)

        // MARK: Child Action
        case boxFinishAlert(PresentationAction<Alert>)

        enum Alert {
            case seeAgain
            case finish
        }
    }

    @Dependency(\.continuousClock) var clock

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce<State, Action> { state, action in
            switch action {
            case ._onTask:
                return .none

            case .binding(\.$musicLinkUrlInput):
                state.showInvalidMusicUrlError = false
                return .none

            case .musicBottomSheetBackButtonTapped:
                guard state.musicBottomSheetMode != .choice else { return .none }
                state.musicLinkUrlInput = ""
                state.selectedMusicUrl = nil
                state.musicBottomSheetMode = .choice
                return changeDetentsForSmoothAnimation(for: .choice)

            case .musicChoiceUserSelectButtonTapped:
                state.musicBottomSheetMode = .userSelect
                return changeDetentsForSmoothAnimation(for: .userSelect)

            case .musicChoiceRecommendButtonTapped:
                state.musicBottomSheetMode = .recommend
                return changeDetentsForSmoothAnimation(for: .recommend)

            case .musicLinkConfirmButtonTapped:
                // TODO: 서버 통신해서 유효성 검사
                // state.musicLinkUrlInput 가지고 서버 validation...
                let isValidMusicUrl: Bool = .random()

                guard isValidMusicUrl else {
                    state.showInvalidMusicUrlError = false
                    return .none
                }

                state.selectedMusicUrl = .init(stringLiteral: state.musicLinkUrlInput)
                return .none

            case .musicLinkSaveButtonTapped:
                // TODO: 서버 통신해서 저장
                return .none

            case .musicLinkDeleteButtonTapped:
                state.musicLinkUrlInput = ""
                state.selectedMusicUrl = nil
                return .none

            case let ._setDetents(detents):
                state.musicSheetDetents = detents
                return .none

            case .nextButtonTapped:
                state.boxFinishAlert = AlertState {
                    TextState("선물박스를 완성할까요?")
                } actions: {
                    ButtonState(action: .seeAgain) {
                        TextState("다시 볼게요")
                    }

                    ButtonState(action: .finish) {
                        TextState("완성할래요")
                    }
                } message: {
                    TextState("완성한 이후에는 수정할 수 없어요")
                }
                
                return .none

            default:
                return .none
            }
        }
    }
}

private extension BoxStartGuideFeature {
    /// 바텀시트의 detent를 변경함으로서 사이즈를 조절할 때, 가능한 detents들에 전후의 detent가 포함되어 있어야 애니메이션 적용됨
    /// 하지만, 모두 주면 아예 detent 를 변경할 수 있는 형태가 되기에, 0.1 초 후에 detents 변경
    func changeDetentsForSmoothAnimation(for mode: MusicBottomSheetMode) -> Effect<Action> {
        .run { send in
            await send(._setDetents(MusicBottomSheetMode.allDetents))
            try? await clock.sleep(for: .seconds(0.1))
            await send(._setDetents([mode.detent]))
        }
    }
}

enum MusicBottomSheetMode: CaseIterable {
    case choice
    case userSelect
    case recommend

    var detent: PresentationDetent {
        switch self {
        case .choice:
            return .height(383)
        case .userSelect, .recommend:
            return .large
        }
    }

    static var allDetents: Set<PresentationDetent> {
        Set(Self.allCases.map(\.detent))
    }
}
