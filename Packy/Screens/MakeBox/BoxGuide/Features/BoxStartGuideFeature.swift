//
//  BoxStartGuideFeature.swift
//  Packy
//
//  Created Mason Kim on 1/13/24.
//

import Foundation
import ComposableArchitecture
import SwiftUI

@Reducer
struct BoxStartGuideFeature: Reducer {

    struct State: Equatable {
        let senderInfo: BoxSenderInfo
        let boxDesigns: [BoxDesign]
        var selectedBox: BoxDesign?

        var isShowingGuideText: Bool = false

        @BindingState var addPhoto: BoxAddPhotoFeature.State = .init()

        @BindingState var isMusicBottomSheetPresented: Bool = false
        @BindingState var isLetterBottomSheetPresented: Bool = false

        @BindingState var isStickerBottomSheetPresented: Bool = false
        @BindingState var isSelectBoxBottomSheetPresented: Bool = false
        @BindingState var isAddGiftBottomSheetPresented: Bool = false

        @BindingState var musicInput: MusicInput = .init()

        @BindingState var letterInput: LetterInput = .init()
        var giftInput: GiftInput = .init()

        var savedMusic: MusicInput = .init()
        var savedLetter: LetterInput = .init()
        var savedGift: GiftInput = .init()

        var recommendedMusics: [RecommendedMusic] = []
        var letterDesigns: [LetterDesign] = []
        var stickerDesigns: [StickerDesignResponse] = []
        var selectedStickers: [StickerDesign] = []

        /// 모든 요소가 입력되어서, 완성할 수 있는 상태인지
        var isCompletable: Bool {
            savedMusic.isCompleted &&
            addPhoto.savedPhoto.isCompleted &&
            savedLetter.isCompleted &&
            selectedStickers.count == 2
        }
    }

    enum Action: BindableAction {
        // MARK: User Action
        case binding(BindingAction<State>)

        // 뒤로가기
        case backButtonTapped

        // 완성
        case completeButtonTapped
        case makeBoxAlertConfirmButtonTapped

        // 음악
        case musicSelectButtonTapped
        case musicBottomSheetBackButtonTapped
        case musicChoiceUserSelectButtonTapped
        case musicChoiceRecommendButtonTapped
        case musicLinkConfirmButtonTapped
        case musicSaveButtonTapped
        case musicLinkDeleteButtonTapped
        case musicLinkDeleteButtonInSheetTapped
        case musicBottomSheetCloseButtonTapped
        case closeMusicSheetAlertConfirmTapped

        // 편지
        case letterInputButtonTapped
        case letterSaveButtonTapped
        case letterBottomSheetCloseButtonTapped
        case closeLetterSheetAlertConfirmTapped

        // 스티커
        case fetchMoreStickers
        case stickerTapped(StickerDesign)

        // 박스
        case selectBox(BoxDesign)

        // 선물
        case addGiftButtonTapped
        case selectGiftImage(Data)
        case deleteGiftImageButtonTapped
        case notSelectGiftButtonTapped
        case addGiftSheetCloseButtonTapped
        case closeGiftSheetAlertConfirmTapped
        case giftSaveButtonTapped

        // MARK: Inner Business Action
        case _onTask

        // MARK: Inner SetState Action
        case _setDetents(Set<PresentationDetent>)

        case _setUploadedGiftUrl(URL?)
        case _setIsShowingGuideText(Bool)
        case _setLetterDesigns([LetterDesign])
        case _setRecommendedMusics([RecommendedMusic])
        case _setStickerDesigns(StickerDesignResponse)
        case _setShowInvalidMusicUrlError(Bool)
        case _setSelectedMusicUrl(String)

        // MARK: Child Action
        case addPhoto(BoxAddPhotoFeature.Action)

        // MARK: Delegate Action
        enum Delegate {
            case moveToAddTitle(SendingGiftBox, BoxDesign)
        }
        case delegate(Delegate)
    }

    @Dependency(\.continuousClock) var clock
    @Dependency(\.uploadClient) var uploadClient
    @Dependency(\.designClient) var designClient
    @Dependency(\.userDefaults) var userDefaults
    @Dependency(\.packyAlert) var packyAlert
    @Dependency(\.dismiss) var dismiss

    var body: some Reducer<State, Action> {
        BindingReducer()

        Scope(state: \.addPhoto, action: \.addPhoto) { BoxAddPhotoFeature() }

        giftReducer
        letterReducer
        musicReducer

        Reduce<State, Action> { state, action in
            switch action {
            case .binding:
                return .none

            case .backButtonTapped:
                return .run { _ in await dismiss() }

            case ._onTask:
                return .merge(
                    showGuideTextIfNeeded(),
                    // 디자인들 조회...
                    fetchLetterDesigns(),
                    fetchRecommendedMusics(),
                    fetchStickerDesigns(lastStickerId: 0)
                )

            case .fetchMoreStickers:
                let lastStickerId = state.stickerDesigns.last?.contents.last?.id ?? 0
                return fetchStickerDesigns(lastStickerId: lastStickerId)

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

            case let ._setStickerDesigns(response):
                state.stickerDesigns.append(response)
                return .none

            // MARK: Box

            case let .selectBox(boxDesign):
                state.selectedBox = boxDesign
                return .none

            // MARK: Complete

            case .completeButtonTapped:
                return .run { send in
                    await packyAlert.show(
                        .init(
                            title: "선물박스를 완성할까요?",
                            description: "완성한 이후에는 수정할 수 없어요",
                            cancel: "다시 볼게요",
                            confirm: "완성할래요",
                            confirmAction: {
                                await send(.makeBoxAlertConfirmButtonTapped)
                            }
                        )
                    )
                }

            case .makeBoxAlertConfirmButtonTapped:
                let giftBox = giftBoxFrom(state: state)
                let boxDesign = state.selectedBox ?? .mock
                return .send(.delegate(.moveToAddTitle(giftBox, boxDesign)))

            default:
                return .none
            }
        }
    }
}

// MARK: - Inner Functions

private extension BoxStartGuideFeature {
    func showGuideTextIfNeeded() -> Effect<Action> {
        .concatenate(
            .run { send in
                guard !userDefaults.boolForKey(.didEnteredBoxGuide) else { return }
                await send(._setIsShowingGuideText(true))
                try? await clock.sleep(for: .seconds(Constants.textInteractionDuration))
                await send(._setIsShowingGuideText(false), animation: .spring(duration: 1))
            },
            .run { _ in
                await userDefaults.setBool(true, .didEnteredBoxGuide)
            }
        )
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

    func fetchStickerDesigns(lastStickerId: Int) -> Effect<Action> {
        .run { send in
            do {
                let response = try await designClient.fetchStickerDesigns(lastStickerId)
                await send(._setStickerDesigns(response))
            } catch {
                print(error)
            }
        }
    }

    func giftBoxFrom(state: State) -> SendingGiftBox {
        let senderName = state.senderInfo.sender
        let receiverName = state.senderInfo.receiver
        let boxId = state.selectedBox?.id
        let envelopeId = state.savedLetter.selectedLetterDesign?.id ?? 0
        let letterContent = state.savedLetter.letter
        let youtubeUrl = state.savedMusic.selectedMusicUrl ?? ""
        let photo = Photo(
            photoUrl: state.addPhoto.savedPhoto.photoUrl ?? "",
            description: state.addPhoto.savedPhoto.text,
            sequence: 0
        )

        let gift: Gift?
        if let giftImageUrl = state.savedGift.imageUrl {
            gift = .init(type: "photo", url: giftImageUrl.absoluteString)
        } else {
            gift = nil
        }

        let stickers: [SendingSticker] = state.selectedStickers.enumerated().map { index, stickerDesign in
            SendingSticker(id: stickerDesign.id, location: index)
        }

        return SendingGiftBox(
            name: "",
            senderName: senderName,
            receiverName: receiverName,
            boxId: boxId,
            envelopeId: envelopeId,
            letterContent: letterContent,
            youtubeUrl: youtubeUrl,
            photos: [photo],
            gift: gift,
            stickers: stickers
        )
    }
}
