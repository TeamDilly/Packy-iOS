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
                HStack(alignment: .top) {
                    VStack(spacing: 4) {
                        Text("스티커 붙이기")
                            .packyFont(.heading1)
                            .foregroundStyle(.gray900)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text("최대 2개까지 붙일 수 있어요")
                            .packyFont(.body4)
                            .foregroundStyle(.gray600)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button("확인") {
                        viewStore.send(.binding(.set(\.$isStickerBottomSheetPresented, false)))
                    }
                    .buttonStyle(.text)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 24)

                let columns = [GridItem(spacing: 12), GridItem(spacing: 12), GridItem(spacing: 12)]
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(viewStore.stickerDesigns, id: \.id) { stickerDesign in
                        let index = viewStore.selectedStickers.firstIndex(of: stickerDesign)

                        Button {
                            viewStore.send(.stickerTapped(stickerDesign), animation: .easeInOut)
                        } label: {
                            StickerCell(imageUrl: stickerDesign.imageURL, selectedIndex: index)
                                .aspectRatio(1, contentMode: .fit)
                        }
                        .buttonStyle(.bouncy)
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
    var selectedIndex: Int?

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

            if let selectedIndex {
                Text("\(selectedIndex + 1)")
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
        .animation(.spring, value: selectedIndex)
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
