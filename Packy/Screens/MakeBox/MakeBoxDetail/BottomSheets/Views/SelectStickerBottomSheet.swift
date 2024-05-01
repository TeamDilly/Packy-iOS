//
//  SelectStickerBottomSheet.swift
//  Packy
//
//  Created by Mason Kim on 1/21/24.
//

import SwiftUI
import ComposableArchitecture

struct SelectStickerBottomSheet: View {
    private let store: StoreOf<SelectStickerFeature>

    init(store: StoreOf<SelectStickerFeature>) {
        self.store = store
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HStack(alignment: .top) {
                    Text("스티커 붙이기")
                        .packyFont(.heading2)
                        .foregroundStyle(.gray900)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)

                    Button {
                        store.send(.stickerConfirmButtonTapped)
                    } label: {
                        Image(.xmark)
                    }
                    .frame(width: 40, height: 40)
                    .padding(4)
                }
                .frame(height: 48)
                .padding(.leading, 24)
                .padding(.trailing, 16)
                .padding(.top, 12)
                .padding(.bottom, 8)
                
                let columns = [GridItem(spacing: 12), GridItem(spacing: 12), GridItem(spacing: 12)]
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(store.stickerDesigns.flatMap(\.contents), id: \.id) { stickerDesign in
                        let isSelected = store.selectedStickers[store.selectingStickerType] == stickerDesign

                        StickerCell(imageUrl: stickerDesign.imageUrl, isSelected: isSelected)
                            .aspectRatio(1, contentMode: .fit)
                            .bouncyTapGesture {
                                store.send(.stickerTapped(stickerDesign), animation: .easeInOut)
                            }
                    }
                    
                    if store.stickerDesigns.last?.isLastPage == false {
                        PackyProgress()
                            .onAppear {
                                store.send(.fetchMoreStickers)
                            }
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
    var isSelected: Bool

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 12)
                .fill(.gray100)
                .overlay {
                    NetworkImage(url: imageUrl, contentMode: .fit)
                        .padding(13)
                }
                .cornerRadiusWithBorder(
                    radius: 12,
                    borderColor: .black,
                    lineWidth: isSelected ? 3 : 0
                )
        }
        .animation(.spring, value: isSelected)
    }
}

// MARK: - Preview

#Preview {
    MakeBoxDetailView(
        store: .init(
            initialState: .init(senderInfo: .mock, boxDesigns: .mock, selectedBox: .mock, selectSticker: .init(isStickerBottomSheetPresented: true)),
            reducer: {
                MakeBoxDetailFeature()
                // ._printChanges()
            }
        )
    )
}
