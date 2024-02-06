//
//  BoxStartGuideView+StickerSheet.swift
//  Packy
//
//  Created by Mason Kim on 1/21/24.
//

import SwiftUI
import Kingfisher

// TODO: 하위 뷰, 리듀서로 분리

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
                    ForEach(viewStore.stickerDesigns.flatMap(\.contents), id: \.id) { stickerDesign in
                        let index = viewStore.selectedStickers.firstIndex(of: stickerDesign)
                        
                        StickerCell(imageUrl: stickerDesign.imageUrl, selectedIndex: index)
                            .aspectRatio(1, contentMode: .fit)
                            .bouncyTapGesture {
                                viewStore.send(.stickerTapped(stickerDesign), animation: .easeInOut)
                            }
                    }
                    
                    if viewStore.stickerDesigns.last?.isLastPage == false {
                        ProgressView()
                            .onAppear {
                                viewStore.send(.fetchMoreStickers)
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
    var selectedIndex: Int?
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 12)
                .fill(.gray100)
                .overlay {
                    NetworkImage(url: imageUrl, contentMode: .fit)
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
            initialState: .init(senderInfo: .mock, boxDesigns: .mock, selectedBox: .mock, isStickerBottomSheetPresented: true),
            reducer: {
                BoxStartGuideFeature()
                // ._printChanges()
            }
        )
    )
}
