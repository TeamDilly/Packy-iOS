//
//  BoxStartGuideView+SelectBoxSheet.swift
//  Packy
//
//  Created by Mason Kim on 1/23/24.
//

import SwiftUI
import Kingfisher

extension BoxStartGuideView {
    var selectBoxBottomSheet: some View {
        ScrollView {
            VStack(spacing: 0) {
                Group {
                    Text("박스 고르기")
                        .packyFont(.heading1)
                        .foregroundStyle(.gray900)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 24)
                        .padding(.bottom, 4)

                    Text("마음에 드는 선물박스를 골라주세요")
                        .packyFont(.body4)
                        .foregroundStyle(.gray600)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 32)
                }
                .padding(.horizontal, 24)

                // let columns = [GridItem(spacing: 12), GridItem(spacing: 12), GridItem(spacing: 12)]
                // LazyVGrid(columns: columns, spacing: 12) {
                //     ForEach(0...10, id: \.self) { _ in
                //         StickerCell(imageUrl: "https://picsum.photos/200", selectedNumber: 1)
                //             .aspectRatio(1, contentMode: .fit)
                //     }
                // }
                // .padding(.horizontal, 24)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    BoxStartGuideView(
        store: .init(
            initialState: .init(senderInfo: .mock, selectedBoxIndex: 0, isSelectBoxBottomSheetPresented: true),
            reducer: {
                BoxStartGuideFeature()
                    ._printChanges()
            }
        )
    )
}
