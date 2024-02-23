//
//  WriteLetterBottomSheet.swift
//  Packy
//
//  Created by Mason Kim on 1/20/24.
//

import SwiftUI
import ComposableArchitecture
import Kingfisher

struct WriteLetterBottomSheet: View {
    @Bindable private var store: StoreOf<WriteLetterFeature>

    @FocusState private var isLetterFieldFocused: Bool
    @State private var hideNonInputViews: Bool = false

    init(store: StoreOf<WriteLetterFeature>) {
        self.store = store
    }

    var body: some View {
        VStack(spacing: 0) {
            if !hideNonInputViews {
                Text("편지 쓰기")
                    .packyFont(.heading1)
                    .foregroundStyle(.gray900)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
                    .padding(.bottom, 4)
                    .padding(.horizontal, 24)

                Text("마음을 담은 편지를 써보아요")
                    .packyFont(.body4)
                    .foregroundStyle(.gray600)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 32)
                    .padding(.horizontal, 24)
            }

            PackyTextArea(
                text: $store.letterInput.letter,
                placeholder: "편지에 어떤 마음을 담아볼까요?\n따뜻한 인사, 잊지 못할 추억, 고마웠던 순간까지\n모두 좋아요 :)",
                borderColor: store.letterInput.selectedLetterDesign?.envelopeColor.color ?? .gray200
            )
            .frame(width: 342, height: 300)
            .focused($isLetterFieldFocused)
            .padding(.horizontal, 24)

            if !hideNonInputViews {
                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        ForEach(store.letterDesigns, id: \.id) { letterDesign in
                            let isSelected = store.letterInput.selectedLetterDesign == letterDesign

                            let width: CGFloat = UIScreen.main.isWiderThan375pt ? 118 : 100
                            NetworkImage(url: letterDesign.imageUrl, contentMode: .fit)
                                .frame(width: width, height: width * (96 / 118))
                                .cornerRadiusWithBorder(
                                    radius: 8,
                                    borderColor: letterDesign.envelopeColor.color,
                                    lineWidth: isSelected ? 5 : 0
                                )
                                .bouncyTapGesture {
                                    store.send(.binding(.set(\.letterInput.selectedLetterDesign, letterDesign)))
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

            // Spacer 로 처리할 시, 키보드 숨기는 Tap이 안먹히기에 Rectangle 로 처리
            Rectangle()
                .fill(.clear)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .makeTapToHideKeyboard()

            if !hideNonInputViews {
                PackyButton(title: "저장", colorType: .black) {
                    store.send(.letterSaveButtonTapped)
                }
                .padding(.bottom, 16)
                .padding(.horizontal, 24)
                .disabled(store.letterInput.letter.isEmpty || store.letterInput.selectedLetterDesign == nil)
            }
        }
        .onChange(of: isLetterFieldFocused) { oldValue, newValue in
            // TODO: 차후 왜 focused 에서는 애니메이션이 안먹히는지 확인
            withAnimation(.spring) {
                hideNonInputViews = newValue
            }
        }
        .animation(.spring, value: store.letterInput.selectedLetterDesign)
        // .animation(.spring, value: isLetterFieldFocused)
        .keyboardHideToolbar()
    }
}

// MARK: - Preview

#Preview {
    MakeBoxDetailView(
        store: .init(
            initialState: .init(senderInfo: .mock, boxDesigns: .mock, selectedBox: .mock),
            reducer: {
                MakeBoxDetailFeature()
            }
        )
    )
}
