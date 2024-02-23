//
//  BoxShareView.swift
//  Packy
//
//  Created Mason Kim on 2/21/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct BoxShareView: View {
    private let store: StoreOf<BoxShareFeature>

    init(store: StoreOf<BoxShareFeature>) {
        self.store = store
    }

    var body: some View {
        let isSendState = !store.showCompleteAnimation
        VStack(spacing: 0) {
            Button {
                store.send(.closeButtonTapped)
            } label: {
                Text(isSendState ? "나가기" : "")
                    .packyFont(.body4)
                    .foregroundStyle(.gray600)
                    .frame(width: 53, height: 48)
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .trailing)

            Spacer()

            Group {
                if isSendState {
                    Text("\(store.receiverName)님에게\n선물박스를 보내보세요")
                } else {
                    Text("\(store.receiverName)님을 위한\n선물박스가 완성되었어요!")
                        .textInteraction()
                }
            }
            .packyFont(.heading1)
            .foregroundStyle(.gray900)
            .padding(.top, -24)
            .multilineTextAlignment(.center)

            if isSendState {
                Text(store.boxName)
                    .packyFont(.body4)
                    .foregroundStyle(.gray900)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(
                        Capsule()
                            .fill(.gray100)
                            .stroke(.gray300, style: .init())
                    )
                    .padding(.top, 20)
            } else {
                Spacer()
                    .frame(height: 46)
                    .padding(.top, 20)
            }

            Spacer()

            NetworkImage(url: store.boxNormalUrl, contentMode: .fit)
                .shakeRepeat(.veryWeak)
                .aspectRatio(contentMode: .fit)
                .padding(.horizontal, 80)
                .padding(.bottom, 20)

            Spacer()

            if isSendState {
                VStack(spacing: 8) {
                    PackyButton(title: "카카오톡으로 보내기", colorType: .black) {
                        throttle {
                            store.send(.sendButtonTapped)
                        }
                    }
                    .padding(.horizontal, 24)

                    Button(store.didSendToKakao ? "" : "나중에 보낼래요") {
                        store.send(.sendLaterButtonTapped)
                    }
                    .buttonStyle(.text)
                    .frame(width: 129, height: 34)
                }
                .frame(height: 100)
                .padding(.bottom, 20)
            } else {
                Spacer()
                    .frame(height: 100)
                    .padding(.bottom, 20)
            }
        }
        .showLoading(!store.showCompleteAnimation && store.kakaoMessageImgUrl == nil)
        .navigationBarHidden(true)
        .task {
            await store
                .send(._onTask)
                .finish()
        }
    }
}

// MARK: - Preview

#Preview {
    BoxShareView(
        store: .init(
            initialState: .init(
                data: .init(
                    senderName: "Mason",
                    receiverName: "Moon",
                    boxName: "Box",
                    boxNormalUrl: Constants.mockImageUrl,
                    kakaoMessageImgUrl: Constants.mockImageUrl,
                    boxId: 0
                ),
                showCompleteAnimation: true
            ),
            reducer: {
                BoxShareFeature()
                    ._printChanges()
            }
        )
    )
}
