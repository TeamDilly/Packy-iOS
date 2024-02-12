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
    private let store: StoreOf<WriteLetterFeature>
    @ObservedObject var viewStore: ViewStoreOf<WriteLetterFeature>

    @FocusState private var isLetterFieldFocused: Bool
    @State private var hideNonInputViews: Bool = false

    init(store: StoreOf<WriteLetterFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
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

                Text("마음을 담은 편지를 작성해주세요")
                    .packyFont(.body4)
                    .foregroundStyle(.gray600)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 32)
                    .padding(.horizontal, 24)
            }

            PackyTextArea(
                text: viewStore.$letterInput.letter,
                placeholder: "편지에 어떤 마음을 담아볼까요?\n따뜻한 인사, 잊지 못할 추억, 고마웠던 순간까지\n모두 좋아요 :)",
                borderColor: viewStore.letterInput.selectedLetterDesign?.envelopeColor.color ?? .gray200
            )
            .frame(width: 342, height: 300)
            .focused($isLetterFieldFocused)
            .padding(.horizontal, 24)

            if !hideNonInputViews {
                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        ForEach(viewStore.letterDesigns, id: \.id) { letterDesign in
                            let isSelected = viewStore.letterInput.selectedLetterDesign == letterDesign

                            let width: CGFloat = UIScreen.main.isWiderThan375pt ? 118 : 100
                            NetworkImage(url: letterDesign.imageUrl, contentMode: .fit)
                                .frame(width: width, height: width * (96 / 118))
                                .cornerRadiusWithBorder(
                                    radius: 8,
                                    borderColor: letterDesign.envelopeColor.color,
                                    lineWidth: isSelected ? 5 : 0
                                )
                                .bouncyTapGesture {
                                    viewStore.send(.binding(.set(\.letterInput.$selectedLetterDesign, letterDesign)))
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

            if !hideNonInputViews {
                PackyButton(title: "저장", colorType: .black) {
                    viewStore.send(.letterSaveButtonTapped)
                }
                .padding(.bottom, 16)
                .padding(.horizontal, 24)
                .disabled(viewStore.letterInput.letter.isEmpty || viewStore.letterInput.selectedLetterDesign == nil)
            }
        }
        .onChange(of: isLetterFieldFocused) { oldValue, newValue in
            // TODO: 차후 왜 focused 에서는 애니메이션이 안먹히는지 확인
            withAnimation(.spring) {
                hideNonInputViews = newValue
            }
        }
        .animation(.spring, value: viewStore.letterInput.selectedLetterDesign)
        // .animation(.spring, value: isLetterFieldFocused)
        .keyboardHideToolbar()
        .makeTapToHideKeyboard()
    }
}

// MARK: - Preview

#Preview {
    BoxStartGuideView(
        store: .init(
            initialState: .init(senderInfo: .mock, boxDesigns: .mock, selectedBox: .mock),
            reducer: {
                BoxStartGuideFeature()
            }
        )
    )
}
