//
//  AddGiftBottomSheet.swift
//  Packy
//
//  Created by Mason Kim on 1/24/24.
//

import SwiftUI
import ComposableArchitecture

struct AddGiftBottomSheet: View {
    private let store: StoreOf<AddGiftFeature>

    init(store: StoreOf<AddGiftFeature>) {
        self.store = store
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 4) {
                Text("준비한 선물이 있나요?")
                    .packyFont(.heading1)
                    .foregroundStyle(.gray900)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("선물 이미지를 함께 담아 친구에게 보내보세요")
                    .packyFont(.body4)
                    .foregroundStyle(.gray600)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            PhotoPicker(image: store.giftInput.photoData?.image) { data in
                store.send(.selectGiftImage(data))
            }
            .cropAlignment(.top)
            .deleteButton(isShown: store.giftInput.photoData != nil) {
                store.send(.deleteGiftImageButtonTapped)
            }
            .padding(.top, 32)

            Spacer()

            PackyButton(title: "저장", colorType: .black) {
                store.send(.giftSaveButtonTapped)
            }
            .disabled(store.giftInput.photoData == nil)
            .padding(.bottom, 8)

            Button("안 담을래요") {
                store.send(.notSelectGiftButtonTapped)
            }
            .buttonStyle(TextButtonStyle())
            .padding(.bottom, 20)

        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Preview

#Preview {
    MakeBoxDetailView(
        store: .init(
            initialState: .init(senderInfo: .mock, boxDesigns: .mock, selectedBox: .mock),
            reducer: {
                MakeBoxDetailFeature()
                    ._printChanges()
            }
        )
    )
}
