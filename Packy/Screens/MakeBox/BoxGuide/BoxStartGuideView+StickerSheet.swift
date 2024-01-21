//
//  BoxStartGuideView+StickerSheet.swift
//  Packy
//
//  Created by Mason Kim on 1/21/24.
//

import SwiftUI
import Kingfisher

extension BoxStartGuideView {
    var addStickerBottomSheet: some View {
        ScrollView {
            VStack(spacing: 0) {
                Group {
                    Text("스티커 붙이기")
                        .packyFont(.heading1)
                        .foregroundStyle(.gray900)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 24)
                        .padding(.bottom, 4)

                    Text("최대 2개까지 붙일 수 있어요")
                        .packyFont(.body4)
                        .foregroundStyle(.gray600)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 32)
                }
                .padding(.horizontal, 24)

                let columns = [GridItem(spacing: 12), GridItem(spacing: 12), GridItem(spacing: 12)]
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(0...10, id: \.self) { _ in
                        StickerCell(imageUrl: "https://picsum.photos/200", selectedNumber: 1)
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

// MARK: - Inner Views

private struct StickerCell: View {
    var imageUrl: String
    var selectedNumber: Int?

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 12)
                .fill(.gray100)
                .overlay {
                    KFImage(URL(string: imageUrl))
                        .placeholder {
                            ProgressView()
                                .progressViewStyle(.circular)
                        }
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .padding(20)
                }

            if let selectedNumber {
                Text("\(selectedNumber)")
                    .packyFont(.body1)
                    .foregroundStyle(.white)
                    .background(
                        Circle()
                            .fill(.black)
                            .frame(width: 24, height: 24)
                    )
                    .padding(.top, 8)
                    .padding(.trailing, 16)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    BoxStartGuideView(
        store: .init(
            initialState: .init(senderInfo: .mock, selectedBoxIndex: 0, isStickerBottomSheetPresented: true),
            reducer: {
                BoxStartGuideFeature()
                    ._printChanges()
            }
        )
    )
}
