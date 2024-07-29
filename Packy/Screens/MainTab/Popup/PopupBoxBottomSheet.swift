//
//  PopupBoxBottomSheet.swift
//  Packy
//
//  Created by Mason Kim on 2/22/24.
//

import SwiftUI
import ComposableArchitecture

@ViewAction(for: PopupGiftBoxFeature.self)
struct PopupBoxBottomSheet: View {
    let store: StoreOf<PopupGiftBoxFeature>

    var body: some View {
        if let popupBox = store.popupBox {
            VStack(spacing: 0) {
                Text("패키가 보낸\n선물박스가 도착했어요!")
                    .packyFont(.heading1)
                    .foregroundStyle(.gray900)
                    .multilineTextAlignment(.center)

                Text(popupBox.name)
                    .packyFont(.body4)
                    .foregroundStyle(.gray900)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(
                        Capsule()
                            .fill(.gray100)
                            .stroke(.gray300, style: .init())
                    )
                    .padding(.top, 16)

                NetworkImage(url: popupBox.normalImgUrl)
                    .shakeRepeat(.veryWeak)
                    .frame(width: 160, height: 160)
                    .padding(.top, 40)
                    .padding(.bottom, 48)
                    .bouncyTapGesture {
                        throttle(.seconds(3)) {
                            send(.openButtonTapped)
                        }
                    }

                PackyButton(title: "열어보기", colorType: .black) {
                    throttle(.seconds(3)) {
                        send(.openButtonTapped)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    PopupBoxBottomSheet(
        store: .init(
            initialState: PopupGiftBoxFeature.State(),
            reducer: {
                PopupGiftBoxFeature()
            })
    )
}
