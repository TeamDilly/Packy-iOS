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
    @ObservedObject private var viewStore: ViewStoreOf<BoxShareFeature>

    init(store: StoreOf<BoxShareFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        let isSendState = !viewStore.showCompleteAnimation
        VStack(spacing: 0) {
            Button {
                viewStore.send(.closeButtonTapped)
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
                    Text("\(viewStore.receiverName)님에게\n선물박스를 보내보세요")
                } else {
                    Text("\(viewStore.receiverName)님을 위한\n선물박스가 완성되었어요!")
                        .textInteraction()
                }
            }
            .packyFont(.heading1)
            .foregroundStyle(.gray900)
            .padding(.top, -24)
            .multilineTextAlignment(.center)

            if isSendState {
                Text(viewStore.boxName)
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

            NetworkImage(url: viewStore.boxNormalUrl, contentMode: .fit)
                .shakeRepeat(.veryWeak)
                .aspectRatio(contentMode: .fit)
                .padding(.horizontal, 80)
                .padding(.bottom, 20)

            Spacer()

            if isSendState {
                VStack(spacing: 8) {
                    PackyButton(title: "카카오톡으로 보내기", colorType: .black) {
                        throttle {
                            viewStore.send(.sendButtonTapped)
                        }
                    }
                    .padding(.horizontal, 24)

                    Button("나중에 보낼래요") {
                        viewStore.send(.sendLaterButtonTapped)
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
        .task {
            await viewStore
                .send(._onTask)
                .finish()
        }
    }
}

// MARK: - Preview

#Preview {
    BoxShareView(
        store: .init(
            initialState: .init(senderName: "Mason", receiverName: "Moon", boxName: "Box", boxNormalUrl: Constants.mockImageUrl, kakaoMessageImgUrl: Constants.mockImageUrl, boxId: 0, showCompleteAnimation: true),
            reducer: {
                BoxShareFeature()
                    ._printChanges()
            }
        )
    )
}
