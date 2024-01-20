//
//  BoxStartGuideView+LetterSheet.swift
//  Packy
//
//  Created by Mason Kim on 1/20/24.
//

import SwiftUI


extension BoxStartGuideView {
    var letterBottomSheet: some View {
        VStack(spacing: 0) {
            Text("편지 쓰기")
                .packyFont(.heading1)
                .foregroundStyle(.gray900)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 8)
                .padding(.bottom, 4)

            Text("마음을 담은 편지를 작성해주세요")
                .packyFont(.body4)
                .foregroundStyle(.gray600)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 32)

            PackyTextArea(
                text: viewStore.$letterInput.letter,
                placeholder: "어떤 마음을 담아볼까요?\n따뜻한 인사, 잊지 못할 추억, 고마웠던 순간까지\n모두 좋아요 :)"
            )
            // .focused(<#T##FocusState<Bool>.Binding#>)

            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Preview

#Preview {
    BoxStartGuideView(
        store: .init(
            initialState: .init(senderInfo: .mock, selectedBoxIndex: 0, isLetterBottomSheetPresented: true),
            reducer: {
                BoxStartGuideFeature()
            }
        )
    )
}
