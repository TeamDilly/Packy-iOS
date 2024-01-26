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
        var isCompleted: Bool { selectedMusicUrl != nil }
    }

    struct PhotoInput: Equatable {
        var photoUrl: String?
        var text: String = ""
        var isCompleted: Bool { text.isEmpty == false }
        var isSaved: Bool = false
    }

    struct LetterInput: Equatable {
        @BindingState var selectedLetterDesign: LetterDesign?
        var letter: String = ""
        var isCompleted: Bool { letter.isEmpty == false }
        var isSaved: Bool = false
    }

    struct State: Equatable {
        let senderInfo: BoxSenderInfo
        let boxDesigns: [BoxDesign]
        var selectedBox: BoxDesign?

        var isShowingGuideText: Bool = true

        @BindingState var isMusicBottomSheetPresented: Bool = false
        @BindingState var isLetterBottomSheetPresented: Bool = false
        @BindingState var isPhotoBottomSheetPresented: Bool = false
        @BindingState var isStickerBottomSheetPresented: Bool = false
        @BindingState var isSelectBoxBottomSheetPresented: Bool = false
        @BindingState var isAddGiftBottomSheetPresented: Bool = false

        @BindingState var musicInput: MusicInput = .init()
        @BindingState var photoInput: PhotoInput = .init()
        @BindingState var letterInput: LetterInput = .init()

        var recommendedMusics: [RecommendedMusic] = []
        var letterDesigns: [LetterDesign] = []

        var stickerDesigns: [StickerDesign] = []
        var selectedStickers: [StickerDesign] = []

        var giftimageUrl: URL?

        /// 모든 요소가 입력되어서, 완성할 수 있는 상태인지
        var isCompletable: Bool {
            musicInput.isCompleted &&
            photoInput.isCompleted &&
            letterInput.isCompleted &&
            selectedStickers.count == 2
        }
    }

    enum Action: BindableAction {
        // MARK: User Action
        case binding(BindingAction<State>)

        // 음악
        case musicBottomSheetBackButtonTapped
        case musicChoiceUserSelectButtonTapped
        case musicChoiceRecommendButtonTapped
        case musicLinkConfirmButtonTapped
        case musicSaveButtonTapped
        case musicLinkDeleteButtonTapped

        // 사진
        case selectPhoto(Data)
        case photoDeleteButtonTapped
        case photoBottomSheetCloseButtonTapped
        case photoSaveButtonTapped

        // 편지
        case letterSaveButtonTapped
        case letterBottomSheetCloseButtonTapped

        // 스티커
        case stickerTapped(StickerDesign)

        // 박스
        case selectBox(BoxDesign)

        // 선물
        case selectGiftImage(Data)
        case deleteGiftImageButtonTapped
        case notSelectGiftButtonTapped
        case addGiftSheetCloseButtonTapped
        case closeGiftSheetAlertConfirmTapped

        // 완성
        case completeButtonTapped
        case makeBoxConfirmButtonTapped

        // MARK: Inner Business Action
        case _onTask

        // MARK: Inner SetState Action
        case _setDetents(Set<PresentationDetent>)
        case _setUploadedPhotoUrl(String?)
        case _setUploadedGiftUrl(URL?)
        case _setIsShowingGuideText(Bool)
        case _setLetterDesigns([LetterDesign])
        case _setRecommendedMusics([RecommendedMusic])
        case _setStickerDesigns([StickerDesign])

        // MARK: Child Action
    }

    @Dependency(\.continuousClock) var clock
    @Dependency(\.uploadClient) var uploadClient
    @Dependency(\.designClient) var designClient
    @Dependency(\.userDefaults) var userDefaults
    @Dependency(\.packyAlert) var packyAlert

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce<State, Action> { state, action in
            switch action {
            case .binding:
                return .none

            case ._onTask:
                return .merge(
                    .run { _ in
                        await userDefaults.setBool(true, .didEnteredBoxGuide)
                    },
                    .run { send in
                        try? await clock.sleep(for: .seconds(1))
                        await send(._setIsShowingGuideText(false), animation: .spring)
                    },
                    // 디자인들 조회...
                    fetchLetterDesigns(),
                    fetchRecommendedMusics(),
                    fetchStickerDesigns()
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
                state.musicInput = .init(selectedMusicUrl: selectedMusicUrl)
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
                    await send(._setUploadedPhotoUrl(response.uploadedFileUrl))
                }

            case let ._setUploadedPhotoUrl(url):
                state.photoInput.photoUrl = url
                return .none

            case .photoDeleteButtonTapped:
                state.photoInput.photoUrl = nil
                return .none

            case .photoBottomSheetCloseButtonTapped:
                guard state.photoInput.isSaved == false else { return .none }
                state.photoInput = .init()
                return .none

            case .photoSaveButtonTapped:
                state.photoInput.isSaved = true
                state.isPhotoBottomSheetPresented = false
                return .none

            // MARK: Letter

            case .letterSaveButtonTapped:
                state.letterInput.isSaved = true
                state.isLetterBottomSheetPresented = false
                return .none

            case .letterBottomSheetCloseButtonTapped:
                guard state.letterInput.isSaved == false else { return .none }
                state.letterInput = .init()
                return .none

            // MARK: Sticker

            case let .stickerTapped(sticker):
                // 이미 해당 스티커가 존재하면 삭제
                if let index = state.selectedStickers.firstIndex(of: sticker) {
                    state.selectedStickers.remove(at: index)
                    return .none
                }

                // 2개 까지만 선택
                guard state.selectedStickers.count < 2 else { return .none }
                state.selectedStickers.append(sticker)
                return .none

            case let ._setStickerDesigns(designs):
                state.stickerDesigns = designs
                return .none

            // MARK: Box

            case let .selectBox(boxDesign):
                state.selectedBox = boxDesign
                return .none

            // MARK: Gift

            case let .selectGiftImage(data):
                return .run { send in
                    let response = try await uploadClient.upload(.init(fileName: "\(UUID()).png", data: data))
                    await send(._setUploadedGiftUrl(URL(string: response.uploadedFileUrl)))
                }

            case let ._setUploadedGiftUrl(url):
                state.giftimageUrl = url
                return .none

            case .deleteGiftImageButtonTapped:
                state.giftimageUrl = nil
                return .none

            case .notSelectGiftButtonTapped, .closeGiftSheetAlertConfirmTapped:
                state.giftimageUrl = nil
                state.isAddGiftBottomSheetPresented = false
                return .none

            case .addGiftSheetCloseButtonTapped:
                return .run { send in
                    await packyAlert.show(
                        .init(title: "선물탭을 진짜 닫겠는가", description: "진짜루?", cancel: "놉,,", confirm: "예쓰", confirmAction: {
                            await send(.closeGiftSheetAlertConfirmTapped)
                        })
                    )
                }

            // MARK: Complete

            case .completeButtonTapped:
                return .run { send in
                    await packyAlert.show(
                        .init(title: "선물박스를 완성할까요?", description: "완성한 이후에는 수정할 수 없어요", cancel: "다시 볼게요", confirm: "완성할래요", confirmAction: {
                            await send(.makeBoxConfirmButtonTapped)
                        })
                    )
                }

            case .makeBoxConfirmButtonTapped:
                // TODO: 실제 서버 통신해서 박스 만드는 과정 마무리
                return .none

            }
        }
    }
}

// private extension BoxStartGuideFeature {
//     var musicReducer: some Reducer {
//         Reduce { state, action in
// 
//         }
//     }
// }

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

    func fetchLetterDesigns() -> Effect<Action> {
        .run { send in
            do {
                let letterDesigns = try await designClient.fetchLetterDesigns()
                await send(._setLetterDesigns(letterDesigns))
            } catch {
                print(error)
            }
        }
    }

    func fetchRecommendedMusics() -> Effect<Action> {
        .run { send in
            do {
                let recommendedMusics = try await designClient.fetchRecommendedMusics()
                await send(._setRecommendedMusics(recommendedMusics))
            } catch {
                print(error)
            }
        }
    }

    func fetchStickerDesigns() -> Effect<Action> {
        .run { send in
            do {
                let stickerDesigns = try await designClient.fetchStickerDesigns()
                await send(._setStickerDesigns(stickerDesigns))
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
