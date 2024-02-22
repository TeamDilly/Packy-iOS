//
//  PackyBoxBottomSheet.swift
//  Packy
//
//  Created by Mason Kim on 2/22/24.
//

import SwiftUI
import ComposableArchitecture

struct PackyBoxBottomSheet: View {
    private let store: StoreOf<PackyBoxFeature>
    @ObservedObject private var viewStore: ViewStoreOf<PackyBoxFeature>

    init(store: StoreOf<PackyBoxFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        if let giftBox = viewStore.packyBox {
            VStack(spacing: 0) {
                Text("패키가 보낸\n선물박스가 도착했어요!")
                    .packyFont(.heading1)
                    .foregroundStyle(.gray900)
                    .multilineTextAlignment(.center)

                Text(giftBox.name)
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

                NetworkImage(url: giftBox.box.boxNormalUrl)
                    .shakeRepeat(.veryWeak)
                    .frame(width: 160, height: 160)
                    .padding(.top, 40)
                    .padding(.bottom, 48)
                    .bouncyTapGesture {
                        throttle(.seconds(3)) {

                        }
                    }

                PackyButton(title: "열어보기", colorType: .black) {
                    throttle(.seconds(3)) {

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
    PackyBoxBottomSheet(
        store: .init(
            initialState: PackyBoxFeature.State(),
            reducer: {
                PackyBoxFeature()
            })
    )
}
