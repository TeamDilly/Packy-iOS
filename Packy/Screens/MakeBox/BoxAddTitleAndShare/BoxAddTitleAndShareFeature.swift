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

    @ObservableState
    struct State: Equatable {
        var giftBoxData: SendingGiftBoxRawData
        var giftBox: SendingGiftBox?
        let boxDesign: BoxDesign

        /// 보내는데 성공한 박스 정보
        fileprivate var sentGiftBoxInfo: SentGiftBoxInfo?

        var boxNameInput: String = ""

        var isLoading: Bool = false
        var boxShare: BoxShareFeature.State?

        init(giftBoxData: SendingGiftBoxRawData, giftBox: SendingGiftBox? = nil, boxDesign: BoxDesign) {
            self.giftBoxData = giftBoxData
            self.giftBox = giftBox
            self.boxDesign = boxDesign
        }
    }

    enum Action: ViewAction {
        case view(View)
        case delegate(Delegate)

        case saveGiftBox
        case setUploadedGiftUrl(String)
        case setUploadedPhotoUrl(String)
        case changeScreenToShare
        case setSentGiftBoxInfo(SentGiftBoxInfo)
        case showErrorMessage(String)
        case showIsLoading(Bool)

        // MARK: Child Action
        case boxShare(BoxShareFeature.Action)

        enum View: BindableAction {
            case onTask
            case binding(BindingAction<State>)
            case backButtonTapped
            case nextButtonTapped
        }

        enum Delegate {
            case moveToHome
        }
    }

    @Dependency(\.continuousClock) var clock
    @Dependency(\.boxClient) var boxClient
    @Dependency(\.uploadClient) var uploadClient
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.packyAlert) var packyAlert

    var body: some Reducer<State, Action> {
        BindingReducer(action: \.view)
        
        Reduce<State, Action> { state, action in
            switch action {
            case let .view(action):
                switch action {
                case .backButtonTapped:
                    return .run { _ in await dismiss() }

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
                        .send(.saveGiftBox)
                    )

                default:
                    return .none
                }

            case .saveGiftBox:
                return saveGiftBox(state)
                    .throttle(id: "saveGiftBox", for: .seconds(3), scheduler: DispatchQueue.main, latest: false)

            case let .setUploadedPhotoUrl(url):
                state.giftBox?.photos[0].photoUrl = url
                return .none

            case let .setUploadedGiftUrl(url):
                state.giftBox?.gift?.url = url
                return .none

            case let .setSentGiftBoxInfo(sentGiftBoxInfo):
                state.sentGiftBoxInfo = sentGiftBoxInfo
                return .send(.changeScreenToShare)

            case .changeScreenToShare:
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

            case let .showErrorMessage(errorMessage):
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

            case let .showIsLoading(isLoading):
                state.isLoading = isLoading
                return .none

            case .boxShare(.closeButtonTapped),
                    .boxShare(.sendLaterButtonTapped):
                return .send(.delegate(.moveToHome))

            default:
                return .none
            }
        }
        .ifLet(\.boxShare, action: \.boxShare) {
            BoxShareFeature()
        }
    }
}


// MARK: - Inner Functions

private extension BoxAddTitleAndShareFeature {
    func uploadPhotoImage(data: Data) -> Effect<Action> {
        return .run { send in
            let response = try await uploadClient.upload(.init(fileName: "\(UUID()).png", data: data))
            await send(.setUploadedPhotoUrl(response.uploadedFileUrl))
        }
    }

    func uploadGiftImageIfNeeded(data: Data?) -> Effect<Action> {
        guard let data else { return .none }
        return .run { send in
            let response = try await uploadClient.upload(.init(fileName: "\(UUID()).png", data: data))
            await send(.setUploadedGiftUrl(response.uploadedFileUrl))
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
                await send(.setSentGiftBoxInfo(sentGiftBoxInfo))
            } catch let error as ErrorResponse {
                await send(.showErrorMessage(error.message))
            } catch {
                await send(.showErrorMessage(error.localizedDescription))
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
