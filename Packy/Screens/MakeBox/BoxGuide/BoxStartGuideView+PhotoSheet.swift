//
//  BoxStartGuideView+PhotoSheet.swift
//  Packy
//
//  Created by Mason Kim on 1/19/24.
//

import SwiftUI

extension Int: Identifiable {
    public var id: Int { self }
}

extension BoxStartGuideView {
    var addPhotoBottomSheet: some View {
        VStack(spacing: 0) {
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

            PhotoElement(
                imageURL: viewStore.photoInput.photoUrl,
                text: viewStore.$photoInput.text
            )
            .photoPickable { data in
                guard let data else { return }
                viewStore.send(.selectPhoto(data))
            }
            .deleteButton(isShown: viewStore.photoInput.photoUrl != nil) {
                viewStore.send(.photoDeleteButtonTapped)
            }
            .frame(height: 374)

            Spacer()

            PackyButton(title: "저장", colorType: .black) {
                viewStore.send(.photoSaveButtonTapped)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
    }
}

// MARK: - Preview

#Preview {
    BoxStartGuideView(
        store: .init(
            initialState: .init(senderInfo: .mock, selectedBoxIndex: 0, isPhotoBottomSheetPresented: true),
            reducer: {
                BoxStartGuideFeature()
                    ._printChanges()
            }
        )
    )
}
