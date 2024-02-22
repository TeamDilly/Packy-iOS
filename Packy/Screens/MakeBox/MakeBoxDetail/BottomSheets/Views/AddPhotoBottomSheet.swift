//
//  AddPhotoBottomSheet.swift
//  Packy
//
//  Created by Mason Kim on 1/19/24.
//

import SwiftUI
import ComposableArchitecture

struct AddPhotoBottomSheet: View {
    private let store: StoreOf<AddPhotoFeature>
    @ObservedObject var viewStore: ViewStoreOf<AddPhotoFeature>
    @FocusState private var textFieldFocused: Bool

    init(store: StoreOf<AddPhotoFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
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
                image: viewStore.photoInput.photoData?.image,
                text: viewStore.$photoInput.text
            )
            .photoPickable { data in
                guard let data else { return }
                viewStore.send(.selectPhoto(data))
            }
            .deleteButton(isShown: viewStore.photoInput.photoData != nil) {
                viewStore.send(.photoDeleteButtonTapped)
            }
            .focused($textFieldFocused)
            .frame(height: 374)

            Spacer()

            if !textFieldFocused {
                PackyButton(title: "저장", colorType: .black) {
                    viewStore.send(.photoSaveButtonTapped)
                }
                .disabled(!viewStore.photoInput.isCompleted)
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
