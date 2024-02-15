//
//  MakeBoxDetailFeature.swift
//  Packy
//
//  Created Mason Kim on 1/13/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct MakeBoxDetailFeature: Reducer {

    struct State: Equatable {
        let senderInfo: BoxSenderInfo
        let boxDesigns: [BoxDesign]
        var selectedBox: BoxDesign?

        var isShowingGuideText: Bool = false

        @BindingState var addPhoto: AddPhotoFeature.State = .init()
        @BindingState var writeLetter: WriteLetterFeature.State = .init()
        @BindingState var selectMusic: SelectMusicFeature.State = .init()
        @BindingState var addGift: AddGiftFeature.State = .init()
        @BindingState var selectSticker: SelectStickerFeature.State = .init()
        @BindingState var isSelectBoxBottomSheetPresented: Bool = false

        /// 모든 요소가 입력되어서, 완성할 수 있는 상태인지
        var isCompletable: Bool {
            selectMusic.savedMusic.isCompleted &&
            addPhoto.savedPhoto.isCompleted &&
            writeLetter.savedLetter.isCompleted &&
            selectSticker.selectedStickers.count == 2
        }
    }

    enum Action: BindableAction {
        // MARK: User Action
        case binding(BindingAction<State>)
        case backButtonTapped
        case completeButtonTapped
        case makeBoxAlertConfirmButtonTapped
        case selectBox(BoxDesign)

        // MARK: Inner Business Action
        case _onTask

        // MARK: Inner SetState Action
        case _setIsShowingGuideText(Bool)

        // MARK: Child Action
        case addPhoto(AddPhotoFeature.Action)
        case writeLetter(WriteLetterFeature.Action)
        case selectMusic(SelectMusicFeature.Action)
        case addGift(AddGiftFeature.Action)
        case selectSticker(SelectStickerFeature.Action)

        // MARK: Delegate Action
        enum Delegate {
            case moveToAddTitle(SendingGiftBoxRawData, BoxDesign)
        }
        case delegate(Delegate)
    }

    @Dependency(\.continuousClock) var clock
    @Dependency(\.userDefaults) var userDefaults
    @Dependency(\.packyAlert) var packyAlert
    @Dependency(\.dismiss) var dismiss

    var body: some Reducer<State, Action> {
        BindingReducer()

        Scope(state: \.addPhoto, action: \.addPhoto) { AddPhotoFeature() }
        Scope(state: \.writeLetter, action: \.writeLetter) { WriteLetterFeature() }
        Scope(state: \.selectMusic, action: \.selectMusic) { SelectMusicFeature() }
        Scope(state: \.addGift, action: \.addGift) { AddGiftFeature() }
        Scope(state: \.selectSticker, action: \.selectSticker) { SelectStickerFeature() }

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
                    .send(.writeLetter(._fetchLetterDesigns)),
                    .send(.selectMusic(._fetchRecommendedMusics)),
                    .send(.selectSticker(._fetchStickerDesigns))
                )

            case let ._setIsShowingGuideText(isShowing):
                state.isShowingGuideText = isShowing
                return .none

            // MARK: Box
            case let .selectBox(boxDesign):
                state.selectedBox = nil
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

private extension MakeBoxDetailFeature {
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

    func giftBoxFrom(state: State) -> SendingGiftBoxRawData {
        let senderName = state.senderInfo.sender
        let receiverName = state.senderInfo.receiver
        let boxId = state.selectedBox?.id
        let envelopeId = state.writeLetter.selectedEnvelopeId
        let letterContent = state.writeLetter.letterContent
        let youtubeUrl = state.selectMusic.savedMusic.selectedMusicUrl ?? ""
        let photo = PhotoRawData(
            photoData: state.addPhoto.savedPhoto.photoData?.data,
            description: state.addPhoto.savedPhoto.text,
            sequence: 0
        )

        let gift: GiftRawData?
        if let giftPhotoData = state.addGift.savedGift.photoData?.data {
            gift = .init(type: "photo", data: giftPhotoData)
        } else {
            gift = nil
        }

        let stickers: [SendingSticker] = state.selectSticker.selectedStickers.enumerated().map { index, stickerDesign in
            SendingSticker(id: stickerDesign.id, location: index)
        }

        return SendingGiftBoxRawData(
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
