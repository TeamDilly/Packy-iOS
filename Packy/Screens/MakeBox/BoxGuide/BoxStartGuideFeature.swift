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

    struct MusicInput: Equatable {
        var musicBottomSheetMode: MusicBottomSheetMode = .choice
        var musicSheetDetents: Set<PresentationDetent> = MusicBottomSheetMode.allDetents

        @BindingState var musicLinkUrlInput: String = "https://www.youtube.com/watch?v=OZRLiBSeAG8"
        var showInvalidMusicUrlError: Bool = false

        var selectedRecommendedMusic: RecommendedMusic? = nil

        /// 최종 유저가 선택한 음악 url
        var selectedMusicUrl: String? = nil
    }

    struct PhotoInput: Equatable {
        var photoUrl: URL?
        var text: String = ""
    }

    struct LetterInput: Equatable {
        @BindingState var selectedLetterDesign: LetterDesign?
        var letter: String = ""
    }

    struct State: Equatable {
        let senderInfo: BoxSenderInfo
        let selectedBoxIndex: Int

        var isShowingGuideText: Bool = true

        @BindingState var isMusicBottomSheetPresented: Bool = false
        @BindingState var isLetterBottomSheetPresented: Bool = false
        @BindingState var isPhotoBottomSheetPresented: Bool = false
        @BindingState var isStickerBottomSheetPresented: Bool = false

        @BindingState var musicInput: MusicInput = .init()
        @BindingState var photoInput: PhotoInput = .init()
        @BindingState var letterInput: LetterInput = .init()

        @BindingState var isShowBoxFinishAlert: Bool = false

        var recommendedMusics: [RecommendedMusic] = []
        var letterDesigns: [LetterDesign] = []
    }

    enum Action: BindableAction {
        // MARK: User Action
        case binding(BindingAction<State>)

        case musicBottomSheetBackButtonTapped
        case musicChoiceUserSelectButtonTapped
        case musicChoiceRecommendButtonTapped
        case musicLinkConfirmButtonTapped
        case musicSaveButtonTapped
        case musicLinkDeleteButtonTapped

        case selectPhoto(Data)
        case photoAddButtonTapped
        case photoSaveButtonTapped
        case photoDeleteButtonTapped

        case letterSaveButtonTapped

        case nextButtonTapped
        case makeBoxConfirmButtonTapped

        // MARK: Inner Business Action
        case _onTask

        // MARK: Inner SetState Action
        case _setDetents(Set<PresentationDetent>)
        case _setUploadedPhotoUrl(URL?)
        case _setIsShowingGuideText(Bool)
        case _setLetterDesigns([LetterDesign])
        case _setRecommendedMusics([RecommendedMusic])

        // MARK: Child Action
    }

    @Dependency(\.continuousClock) var clock
    @Dependency(\.uploadClient) var uploadClient
    @Dependency(\.boxClient) var boxClient

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce<State, Action> { state, action in
            switch action {
            case ._onTask:
                return .merge(
                    .run { send in
                        try? await clock.sleep(for: .seconds(2))
                        await send(._setIsShowingGuideText(false), animation: .spring)
                    },
                    // 디자인들 조회...
                    fetchLetterDesigns(),
                    fetchRecommendedMusics()
                )

            case let ._setIsShowingGuideText(isShowing):
                state.isShowingGuideText = isShowing
                return .none

            // MARK: Set Design

            case let ._setLetterDesigns(letterDesigns):
                state.letterDesigns = letterDesigns
                state.letterInput.selectedLetterDesign = letterDesigns.first
                return .none

            case let ._setRecommendedMusics(recommendedMusics):
                state.recommendedMusics = recommendedMusics
                return .none

            // MARK: Music

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
                // TODO: 서버 통신해서 유효성 검사
                // state.musicLinkUrlInput 가지고 서버 validation...
                let isValidMusicUrl: Bool = .random()

                guard isValidMusicUrl else {
                    state.musicInput.showInvalidMusicUrlError = false
                    return .none
                }

                state.musicInput.selectedMusicUrl = state.musicInput.musicLinkUrlInput
                return .none

            case .musicSaveButtonTapped:
                switch state.musicInput.musicBottomSheetMode {
                case .choice:
                    break
                case .userSelect:
                    state.musicInput.selectedMusicUrl = state.musicInput.musicLinkUrlInput
                case .recommend:
                    state.musicInput.selectedMusicUrl = state.musicInput.selectedRecommendedMusic?.youtubeUrl
                }
                state.isMusicBottomSheetPresented = false
                return .none

            case .musicLinkDeleteButtonTapped:
                state.musicInput.musicLinkUrlInput = ""
                state.musicInput.selectedRecommendedMusic = nil
                state.musicInput.selectedMusicUrl = nil
                return .none

            case let ._setDetents(detents):
                state.musicInput.musicSheetDetents = detents
                return .none

            // MARK: Photo

            case let .selectPhoto(data):
                return .run { send in
                    let response = try await uploadClient.upload(.init(fileName: "\(UUID()).png", data: data))
                    await send(._setUploadedPhotoUrl(URL(string: response.uploadedFileUrl)))
                }

            case let ._setUploadedPhotoUrl(url):
                state.photoInput.photoUrl = url
                return .none

            case .photoDeleteButtonTapped:
                state.photoInput.photoUrl = nil
                return .none

            case .photoSaveButtonTapped:
                state.isPhotoBottomSheetPresented = false
                return .none

            case .nextButtonTapped:
                state.isShowBoxFinishAlert = true
                return .none

            // MARK: Letter

            case .letterSaveButtonTapped:
                state.isLetterBottomSheetPresented = false
                return .none

            case .makeBoxConfirmButtonTapped:
                // TODO: 실제 서버 통신해서 박스 만드는 과정 마무리
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

    func fetchLetterDesigns() -> Effect<Action> {
        .run { send in
            do {
                let letterDesigns = try await boxClient.fetchLetterDesigns()
                await send(._setLetterDesigns(letterDesigns))
            } catch {
                print(error)
            }
        }
    }

    func fetchRecommendedMusics() -> Effect<Action> {
        .run { send in
            do {
                let recommendedMusics = try await boxClient.fetchRecommendedMusics()
                await send(._setRecommendedMusics(recommendedMusics))
            } catch {
                print(error)
            }
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
