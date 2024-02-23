//
//  AddPhotoBottomSheet.swift
//  Packy
//
//  Created by Mason Kim on 1/19/24.
//

import SwiftUI
import ComposableArchitecture

struct AddPhotoBottomSheet: View {
    @Bindable private var store: StoreOf<AddPhotoFeature>
    @FocusState private var textFieldFocused: Bool

    init(store: StoreOf<AddPhotoFeature>) {
        self.store = store
    }

    var body: some View {
        VStack(spacing: 0) {
            if !textFieldFocused {
                Group {
                    Text("추억 사진 담기")
                        .packyFont(.heading1)
                        .foregroundStyle(.gray900)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 8)
                        .padding(.bottom, 4)

                    Text("한 장의 사진으로 소중한 추억을 나눠요\n사진과 함께 그 날의 이야기도 적어볼까요?")
                        .packyFont(.body4)
                        .foregroundStyle(.gray600)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 32)
                }
                .padding(.horizontal, 24)
            }

            PhotoElementInputView(
                image: store.photoInput.photoData?.image,
                text: $store.photoInput.text
            )
            .photoPickable { data in
                guard let data else { return }
                store.send(.selectPhoto(data))
            }
            .deleteButton(isShown: store.photoInput.photoData != nil) {
                store.send(.photoDeleteButtonTapped)
            }
            .focused($textFieldFocused)
            .frame(height: 374)

            Spacer()

            if !textFieldFocused {
                PackyButton(title: "저장", colorType: .black) {
                    store.send(.photoSaveButtonTapped)
                }
                .disabled(!store.photoInput.isCompleted)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
        }
        .keyboardHideToolbar()
        .makeTapToHideKeyboard()
        .animation(.spring, value: textFieldFocused)
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
