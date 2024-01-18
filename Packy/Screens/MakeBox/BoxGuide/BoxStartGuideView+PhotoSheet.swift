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

            CarouselView(items: [0, 1], itemWidth: 312, itemPadding: 24) { index in
                PhotoElement(
                    imageURL: viewStore.photoInputs[index].photoUrl,
                    text: viewStore.$photoInputs[index].text,
                    infoText: "\(viewStore.filledPhotoInputCount)/\(viewStore.photoInputs.count)",
                    isPrimaryPhoto: index == 0
                ) {
                    viewStore.send(.photoAddButtonTapped(index))
                }
                .frame(height: 374)
            }
            .frame(height: 374)
            .border(Color.black)

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
            initialState: .init(),
            reducer: {
                BoxStartGuideFeature()
                // ._printChanges()
            }
        )
    )
}
