//
//  BoxChoiceView.swift
//  Packy
//
//  Created Mason Kim on 1/14/24.
//

import SwiftUI
import ComposableArchitecture
import Lottie

// MARK: - View

struct BoxChoiceView: View {
    private let store: StoreOf<BoxChoiceFeature>

    init(store: StoreOf<BoxChoiceFeature>) {
        self.store = store
    }

    var body: some View {
        let isWiderThan375pt = UIScreen.main.isWiderThan375pt
        VStack(spacing: 0) {
            if store.isPresentingFinishedMotionView {
                finishedBoxMotionView
            } else {
                NavigationBar.backAndCloseButton(
                    backButtonAction: {
                        store.send(.backButtonTapped)
                    },
                    closeButtonAction: {
                        store.send(.closeButtonTapped)
                    }
                )
                .padding(.top, 8)

                Text("마음에 드는 선물박스를\n골라주세요")
                    .packyFont(.heading1)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.gray900)
                    .padding(.top, isWiderThan375pt ? 48 : 30)

                VStack(spacing: isWiderThan375pt ? 64 : 40) {
                    if let selectedBox = store.selectedBox {
                        let boxWidth: CGFloat = isWiderThan375pt ? 232 : 200
                        let boxHeight: CGFloat = boxWidth * (260 / 232)

                        NetworkImage(url: selectedBox.boxSetUrl, contentMode: .fit)
                            .transition(.move(edge: .trailing))
                            .animation(nil, value: store.selectedBox)
                            .frame(width: boxWidth, height: boxHeight)

                        ScrollView(.horizontal) {
                            HStack(spacing: 12) {
                                ForEach(store.boxDesigns, id: \.id) { boxDesign in
                                    NetworkImage(url: boxDesign.boxSmallUrl, contentMode: .fit)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .frame(width: 64, height: 64)
                                        .bouncyTapGesture {
                                            store.send(.selectBox(boxDesign))
                                        }
                                }
                            }
                        }
                        .animation(.spring, value: store.boxDesigns)
                        .transition(.move(edge: .trailing))
                        .scrollIndicators(.hidden)
                        .safeAreaPadding(.horizontal, 40)
                    }
                }
                .padding(.top, isWiderThan375pt ? 60 : 48)

                Spacer()

                PackyButton(title: "다음", colorType: .black) {
                    store.send(.nextButtonTapped)
                }
                .disabled(store.selectedBox == nil)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
        }
        .animation(.spring, value: store.isPresentingFinishedMotionView)
        .animation(.spring, value: store.selectedBox)
        .navigationBarBackButtonHidden(true)
        .task {
            await store
                .send(._onTask)
                .finish()
        }
    }
}

// MARK: - Inner Views

private extension BoxChoiceView {
    @ViewBuilder
    var finishedBoxMotionView: some View {
        ZStack {
            VStack {
                Text("이제 선물박스를\n채우러 가볼까요?")
                    .packyFont(.heading1)
                    .textInteraction(initialDelay: 0.5)
                    .foregroundStyle(.gray900)
                    .padding(.top, 104)
            
                Spacer()
            }

            BoxMotionView(
                motionType: .makeBox(boxDesignId: store.selectedBox?.id ?? 0)
            )
        }
    }
}

// MARK: - Preview

#Preview {
    BoxChoiceView(
        store: .init(
            initialState: .init(senderInfo: .mock),
            reducer: {
                BoxChoiceFeature()
                    ._printChanges()
            }
        )
    )
}
