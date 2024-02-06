//
//  BoxStartGuideView+LetterSheet.swift
//  Packy
//
//  Created by Mason Kim on 1/20/24.
//

import SwiftUI
import ComposableArchitecture
import Kingfisher

// TODO: 하위 뷰, 리듀서로 분리

extension BoxStartGuideView {
    struct LetterBottomSheet: View {
        @ObservedObject var viewStore: ViewStoreOf<BoxStartGuideFeature>
        @FocusState private var isLetterFieldFocused: Bool

        init(viewStore: ViewStoreOf<BoxStartGuideFeature>) {
            self.viewStore = viewStore
        }

        var body: some View {
            VStack(spacing: 0) {
                if !isLetterFieldFocused {
                    Text("편지 쓰기")
                        .packyFont(.heading1)
                        .foregroundStyle(.gray900)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 8)
                        .padding(.bottom, 4)
                        .padding(.horizontal, 24)

                    Text("마음을 담은 편지를 작성해주세요")
                        .packyFont(.body4)
                        .foregroundStyle(.gray600)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 32)
                        .padding(.horizontal, 24)
                }

                PackyTextArea(
                    text: viewStore.$letterInput.letter,
                    placeholder: "어떤 마음을 담아볼까요?\n따뜻한 인사, 잊지 못할 추억, 고마웠던 순간까지\n모두 좋아요 :)",
                    borderColor:
                        // TODO: 기획에 따라 변경 필요
                    viewStore.letterInput.selectedLetterDesign?.borderColor.opacity(0.3) ?? .gray200
                )
                .focused($isLetterFieldFocused)
                .padding(.horizontal, 24)

                if !isLetterFieldFocused {
                    ScrollView(.horizontal) {
                        HStack(spacing: 10) {
                            ForEach(viewStore.letterDesigns, id: \.id) { letterDesign in
                                let isSelected = viewStore.letterInput.selectedLetterDesign == letterDesign
                                KFImage(URL(string: letterDesign.imageUrl))
                                    .placeholder {
                                        ProgressView()
                                            .progressViewStyle(.circular)
                                    }
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadiusWithBorder(
                                        radius: 8,
                                        borderColor: letterDesign.borderColor,
                                        lineWidth: isSelected ? 5 : 0
                                    )
                                    .animation(.spring, value: isSelected)
                                    .bouncyTapGesture {
                                        viewStore.send(.binding(.set(\.letterInput.$selectedLetterDesign, letterDesign)))
                                        HapticManager.shared.fireFeedback(.medium)
                                    }
                                    .padding(.vertical, 5)
                            }
                        }
                    }
                    .safeAreaPadding(.leading, 24)
                    .frame(maxHeight: 100)
                    .scrollIndicators(.hidden)
                    .padding(.top, 16)
                }

                Spacer()

                if !isLetterFieldFocused {
                    PackyButton(title: "저장", colorType: .black) {
                        viewStore.send(.letterSaveButtonTapped)
                    }
                    .padding(.bottom, 16)
                    .padding(.horizontal, 24)
                    .disabled(viewStore.letterInput.letter.isEmpty || viewStore.letterInput.selectedLetterDesign == nil)
                }
            }
            .keyboardHideToolbar()
            .makeTapToHideKeyboard()
            .animation(.spring, value: isLetterFieldFocused)
        }
    }
}

// MARK: - Preview

#Preview {
    BoxStartGuideView(
        store: .init(
            initialState: .init(senderInfo: .mock, boxDesigns: .mock, selectedBox: .mock, isLetterBottomSheetPresented: true),
            reducer: {
                BoxStartGuideFeature()
            }
        )
    )
}
