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
                HStack(alignment: .top) {
                    VStack(spacing: 4) {
                        Text("박스 고르기")
                            .packyFont(.heading1)
                            .foregroundStyle(.gray900)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text("마음에 드는 선물박스를 골라주세요")
                            .packyFont(.body4)
                            .foregroundStyle(.gray600)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button("확인") {
                        viewStore.send(.binding(.set(\.$isSelectBoxBottomSheetPresented, false)))
                    }
                    .buttonStyle(.text)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 24)

                HStack(spacing: 12) {
                    ForEach(viewStore.boxDesigns, id: \.id) { boxDesign in
                        Button {
                            viewStore.send(.selectBox(boxDesign))
                            HapticManager.shared.fireNotification(.success)
                        } label: {
                            NetworkImage(url: boxDesign.boxFullUrl, contentMode: .fit)
                            // KFImage(URL(string: boxDesign.boxFullUrl))
                            //     .placeholder {
                            //         ProgressView()
                            //             .progressViewStyle(.circular)
                            //     }
                            //     .resizable()
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .aspectRatio(1, contentMode: .fit)
                        }
                        .buttonStyle(.bouncy)
                    }
                }
                .padding(.horizontal, 40)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    BoxStartGuideView(
        store: .init(
            initialState: .init(senderInfo: .mock, boxDesigns: .mock, selectedBox: .mock, isSelectBoxBottomSheetPresented: true),
            reducer: {
                BoxStartGuideFeature()
                    ._printChanges()
            }
        )
    )
}
