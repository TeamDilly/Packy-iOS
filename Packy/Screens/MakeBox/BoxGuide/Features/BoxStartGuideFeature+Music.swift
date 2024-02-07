//
//  BoxStartGuideFeature+Music.swift
//  Packy
//
//  Created by Mason Kim on 1/27/24.
//

import ComposableArchitecture
import Foundation
import SwiftUI

extension BoxStartGuideFeature {
    
    // MARK: - Input

    struct MusicInput: Equatable {
        var musicBottomSheetMode: MusicBottomSheetMode = .choice
        var musicSheetDetents: Set<PresentationDetent> = MusicBottomSheetMode.allDetents

        @BindingState var musicLinkUrlInput: String = ""
        var showInvalidMusicUrlError: Bool = false

        @BindingState var selectedRecommendedMusic: RecommendedMusic? = nil

        /// 최종 유저가 선택한 음악 url
        var selectedMusicUrl: String? = nil
        var isCompleted: Bool { selectedMusicUrl != nil }
    }

    // MARK: - Reducer

    var musicReducer: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .musicSelectButtonTapped:
                state.musicInput = state.savedMusic
                state.isMusicBottomSheetPresented = true
                return .none

            case .binding(\.musicInput.$musicLinkUrlInput):
                state.musicInput.showInvalidMusicUrlError = false
                return .none

            case .musicBottomSheetBackButtonTapped:
                guard state.musicInput.musicBottomSheetMode != .choice else { return .none }
                state.musicInput.musicLinkUrlInput = ""
                state.musicInput.selectedRecommendedMusic = nil
                state.musicInput.musicBottomSheetMode = .choice
                return changeDetentsForSmoothAnimation(for: .choice)

            case .musicChoiceUserSelectButtonTapped:
                state.musicInput.musicBottomSheetMode = .userSelect
                return changeDetentsForSmoothAnimation(for: .userSelect)

            case .musicChoiceRecommendButtonTapped:
                state.musicInput.musicBottomSheetMode = .recommend
                return changeDetentsForSmoothAnimation(for: .recommend)

            case .musicLinkConfirmButtonTapped:
                let youtubeLinkUrl = state.musicInput.musicLinkUrlInput
                return .run { send in
                    do {
                        let isValidLink = try await designClient.validateYoutubeUrl(youtubeLinkUrl)
                        await send(._setShowInvalidMusicUrlError(isValidLink))

                        guard isValidLink else { return }
                        await send(._setSelectedMusicUrl(youtubeLinkUrl))
                    } catch {
                        await send(._setShowInvalidMusicUrlError(false))
                    }
                }

            case .musicSaveButtonTapped:
                let selectedMusicUrl: String?
                switch state.musicInput.musicBottomSheetMode {
                case .choice:
                    selectedMusicUrl = nil
                case .userSelect:
                    selectedMusicUrl = state.musicInput.musicLinkUrlInput
                case .recommend:
                    // 첫 번째 요소는 가끔 centeredItem 이 안먹기에, nil이면 첫번째 요소로 지정
                    selectedMusicUrl = (state.musicInput.selectedRecommendedMusic ?? state.recommendedMusics.first)?.youtubeUrl
                }
                state.savedMusic = .init(selectedMusicUrl: selectedMusicUrl)
                state.isMusicBottomSheetPresented = false
                return .none

            case .musicLinkDeleteButtonTapped:
                state.savedMusic = .init()
                return .none

            case .musicLinkDeleteButtonInSheetTapped:
                state.musicInput.musicLinkUrlInput = ""
                state.musicInput.selectedMusicUrl = nil
                return .none

            case let ._setDetents(detents):
                state.musicInput.musicSheetDetents = detents
                return .none

            case let ._setShowInvalidMusicUrlError(isError):
                state.musicInput.showInvalidMusicUrlError = isError
                return .none

            case let ._setSelectedMusicUrl(url):
                state.musicInput.selectedMusicUrl = url
                return .none

            case .musicBottomSheetCloseButtonTapped:
                guard state.savedMusic.isCompleted == false, state.musicInput.isCompleted else {
                    state.isMusicBottomSheetPresented = false
                    return .none
                }

                return .run { send in
                    await packyAlert.show(
                        .init(title: "음악 시트 진짜 닫겠는가?", description: "진짜루?", cancel: "놉,,", confirm: "예쓰", confirmAction: {
                            await send(.closeMusicSheetAlertConfirmTapped)
                        })
                    )
                }

            case .closeMusicSheetAlertConfirmTapped:
                state.musicInput = .init()
                state.isMusicBottomSheetPresented = false
                return .none

            default:
                return .none
            }
        }
    }
}

// MARK: - Inner Functions

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

// MARK: - MusicBottomSheetMode

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
