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

    enum ShowingState {
        case addTitle
        case completed
        case send
    }

    struct State: Equatable {
        var giftBoxData: SendingGiftBoxRawData
        var giftBox: SendingGiftBox?
        let boxDesign: BoxDesign

        @BindingState var boxNameInput: String = ""
        @BindingState var showingState: ShowingState = .addTitle
    }

    enum Action: BindableAction {
        // MARK: User Action
        case binding(BindingAction<State>)
        case backButtonTapped
        case closeButtonTapped
        case nextButtonTapped
        case sendButtonTapped

        // MARK: Inner Business Action
        case _onTask
        case _saveGiftBox
        case _setUploadedGiftUrl(String)
        case _setUploadedPhotoUrl(String)
        case _changeScreen

        // MARK: Inner SetState Action
        case _setBoxId(Int)
        case _showErrorMessage(String)

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
    @Dependency(\.kakaoShare) var kakaoShare
    @Dependency(\.packyAlert) var packyAlert

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce<State, Action> { state, action in
            switch action {
            case .binding:
                return .none

            case .backButtonTapped:
                return .run { _ in await dismiss() }

            case .closeButtonTapped:
                return .send(.delegate(.moveToHome))

            case .nextButtonTapped:
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

            case .sendButtonTapped:
                guard let kakaoMessage = makeKakaoShareMessage(from: state) else { return .none }

                return .run { send in
                    try await kakaoShare.share(kakaoMessage)
                }

            case let ._setUploadedPhotoUrl(url):
                state.giftBox?.photos[0].photoUrl = url
                return .none

            case let ._setUploadedGiftUrl(url):
                state.giftBox?.gift?.url = url
                return .none

            case let ._setBoxId(boxId):
                state.giftBox?.boxId = boxId
                return .none

            case ._changeScreen:
                return .run { send in
                    await send(.binding(.set(\.$showingState, .completed)), animation: .spring)
                    try? await clock.sleep(for: .seconds(2.6))
                    await send(.binding(.set(\.$showingState, .send)), animation: .spring(duration: 1))
                }

            case let ._showErrorMessage(errorMessage):
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

            case ._onTask:
                return .none

            default:
                return .none
            }
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
        guard let giftBox = state.giftBox else { return .none }

        return .run { send in
            do {
                let response = try await boxClient.makeGiftBox(giftBox)
                await send(._setBoxId(response.id))
                await send(._changeScreen)
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
        let imageUrl = state.boxDesign.boxNormalUrl
        let boxId = giftBox.boxId

        return KakaoShareMessage(sender: sender, receiver: receiver, imageUrl: imageUrl, boxId: "\(boxId ?? -1)")
    }
}
