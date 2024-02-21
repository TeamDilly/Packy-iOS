//
//  BoxAddTitleAndShareFeature.swift
//  Packy
//
//  Created Mason Kim on 1/27/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct BoxAddTitleAndShareFeature: Reducer {

    struct State: Equatable {
        var giftBoxData: SendingGiftBoxRawData
        var giftBox: SendingGiftBox?
        let boxDesign: BoxDesign

        /// 보내는데 성공한 박스 정보
        var sentGiftBoxInfo: SentGiftBoxInfo?

        @BindingState var boxNameInput: String = ""

        var isLoading: Bool = false
        @PresentationState var boxShare: BoxShareFeature.State?
    }

    enum Action: BindableAction {
        // MARK: User Action
        case binding(BindingAction<State>)
        case backButtonTapped
        case nextButtonTapped

        // MARK: Inner Business Action
        case _onTask
        case _saveGiftBox
        case _setUploadedGiftUrl(String)
        case _setUploadedPhotoUrl(String)
        case _changeScreenToShare

        // MARK: Inner SetState Action
        case _setSentGiftBoxInfo(SentGiftBoxInfo)
        case _showErrorMessage(String)
        case _showIsLoading(Bool)

        // MARK: Child Action
        case boxShare(PresentationAction<BoxShareFeature.Action>)

        // MARK: Delegate Action
        enum Delegate {
            case moveToHome
            case moveTo
        }
        case delegate(Delegate)
    }

    @Dependency(\.continuousClock) var clock
    @Dependency(\.boxClient) var boxClient
    @Dependency(\.uploadClient) var uploadClient
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.packyAlert) var packyAlert

    var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .backButtonTapped:
                return .run { _ in await dismiss() }

            case .boxShare(.presented(.closeButtonTapped)),
                 .boxShare(.presented(.sendLaterButtonTapped)):
                return .send(.delegate(.moveToHome))

            case .nextButtonTapped:
                guard state.isLoading == false else { return .none }
                state.isLoading = true
                guard let photoData = state.giftBoxData.photos.first?.photoData else { return .none }
                let giftData = state.giftBoxData.gift?.data

                state.giftBox = generateGiftBoxFromData(state.giftBoxData)
                let boxName = state.boxNameInput
                state.giftBox?.name = boxName

                return .concatenate(
                    .merge(
                        uploadPhotoImage(data: photoData),
                        uploadGiftImageIfNeeded(data: giftData)
                    ),
                    .send(._saveGiftBox)
                )

            case ._saveGiftBox:
                return saveGiftBox(state)
                    .throttle(id: "saveGiftBox", for: .seconds(3), scheduler: DispatchQueue.main, latest: false)

            case let ._setUploadedPhotoUrl(url):
                state.giftBox?.photos[0].photoUrl = url
                return .none

            case let ._setUploadedGiftUrl(url):
                state.giftBox?.gift?.url = url
                return .none

            case let ._setSentGiftBoxInfo(sentGiftBoxInfo):
                state.sentGiftBoxInfo = sentGiftBoxInfo
                return .send(._changeScreenToShare)

            case ._changeScreenToShare:
                state.isLoading = false
                state.boxShare = .init(
                    data: .init(
                        senderName: state.giftBoxData.senderName,
                        receiverName: state.giftBoxData.receiverName,
                        boxName: state.giftBox?.name ?? "",
                        boxNormalUrl: state.boxDesign.boxNormalUrl,
                        kakaoMessageImgUrl: state.sentGiftBoxInfo?.kakaoMessageImgUrl ?? state.boxDesign.boxNormalUrl,
                        boxId: state.sentGiftBoxInfo?.id ?? -1
                    ),
                    showCompleteAnimation: true
                )
                return .none

            case let ._showErrorMessage(errorMessage):
                state.isLoading = false
                return .run { send in
                    await packyAlert.show(
                        .init(
                            title: "에러가 발생했어요",
                            description: errorMessage,
                            confirm: "확인",
                            confirmAction: { await dismiss() }
                        )
                    )
                }

            case let ._showIsLoading(isLoading):
                state.isLoading = isLoading
                return .none

            case .binding, ._onTask, .delegate, .boxShare:
                return .none
            }
        }
        .ifLet(\.$boxShare, action: \.boxShare) {
            BoxShareFeature()
        }
    }
}


// MARK: - Inner Functions

private extension BoxAddTitleAndShareFeature {
    func uploadPhotoImage(data: Data) -> Effect<Action> {
        return .run { send in
            let response = try await uploadClient.upload(.init(fileName: "\(UUID()).png", data: data))
            await send(._setUploadedPhotoUrl(response.uploadedFileUrl))
        }
    }

    func uploadGiftImageIfNeeded(data: Data?) -> Effect<Action> {
        guard let data else { return .none }
        return .run { send in
            let response = try await uploadClient.upload(.init(fileName: "\(UUID()).png", data: data))
            await send(._setUploadedGiftUrl(response.uploadedFileUrl))
        }
    }

    func generateGiftBoxFromData(_ giftBoxData: SendingGiftBoxRawData) -> SendingGiftBox {
        let gift: Gift?
        if let giftData = giftBoxData.gift {
            gift = .init(type: giftData.type, url: "")
        } else {
            gift = nil
        }

        return SendingGiftBox(
            name: "",
            senderName: giftBoxData.senderName,
            receiverName: giftBoxData.receiverName,
            boxId: giftBoxData.boxId,
            envelopeId: giftBoxData.envelopeId,
            letterContent: giftBoxData.letterContent,
            youtubeUrl: giftBoxData.youtubeUrl,
            photos: giftBoxData.photos.map { .init(photoUrl: "", description: $0.description, sequence: $0.sequence) },
            gift: gift,
            stickers: giftBoxData.stickers
        )
    }

    func saveGiftBox(_ state: State) -> Effect<Action> {
        guard let giftBox = state.giftBox,
              state.sentGiftBoxInfo == nil else { return .none }

        return .run { send in
            do {
                let sentGiftBoxInfo = try await boxClient.makeGiftBox(giftBox)
                await send(._setSentGiftBoxInfo(sentGiftBoxInfo))
            } catch let error as ErrorResponse {
                await send(._showErrorMessage(error.message))
            } catch {
                await send(._showErrorMessage(error.localizedDescription))
            }
        }
    }

    func makeKakaoShareMessage(from state: State) -> KakaoShareMessage? {
        guard let giftBox = state.giftBox else { return nil }
        let sender = giftBox.senderName
        let receiver = giftBox.receiverName
        let imageUrl = state.sentGiftBoxInfo?.kakaoMessageImgUrl ?? state.boxDesign.boxNormalUrl
        let boxId = state.sentGiftBoxInfo?.id

        return KakaoShareMessage(sender: sender, receiver: receiver, imageUrl: imageUrl, boxId: "\(boxId ?? -1)")
    }
}
