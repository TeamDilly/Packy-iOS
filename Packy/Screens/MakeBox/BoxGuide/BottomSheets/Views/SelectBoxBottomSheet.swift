//
//  SelectBoxBottomSheet.swift
//  Packy
//
//  Created by Mason Kim on 1/23/24.
//

import SwiftUI
import ComposableArchitecture

struct SelectBoxBottomSheet: View {
    @ObservedObject var viewStore: ViewStoreOf<BoxStartGuideFeature>

    init(viewStore: ViewStoreOf<BoxStartGuideFeature>) {
        self.viewStore = viewStore
    }

    var body: some View {
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
                
                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        ForEach(viewStore.boxDesigns, id: \.id) { boxDesign in
                            NetworkImage(url: boxDesign.boxSmallUrl, contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .frame(width: 64, height: 64)
                                .bouncyTapGesture {
                                    viewStore.send(.selectBox(boxDesign), animation: .spring)
                                }
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .safeAreaPadding(.horizontal, 40)
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
