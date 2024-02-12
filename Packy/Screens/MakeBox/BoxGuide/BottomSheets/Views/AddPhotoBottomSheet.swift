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
                    Text("추억을 담은 사진")
                        .packyFont(.heading1)
                        .foregroundStyle(.gray900)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 8)
                        .padding(.bottom, 4)

                    Text("우리의 추억을 담아보세요")
                        .packyFont(.body4)
                        .foregroundStyle(.gray600)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 32)
                }
                .padding(.horizontal, 24)
            }

            PhotoElement(
                imageUrl: viewStore.photoInput.photoUrl,
                text: viewStore.$photoInput.text
            )
            .photoPickable { data in
                guard let data else { return }
                viewStore.send(.selectPhoto(data))
            }
            .deleteButton(isShown: viewStore.photoInput.photoUrl != nil) {
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
    BoxStartGuideView(
        store: .init(
            initialState: .init(senderInfo: .mock, boxDesigns: .mock, selectedBox: .mock),
            reducer: {
                BoxStartGuideFeature()
                    ._printChanges()
            }
        )
    )
}
