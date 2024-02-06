//
//  BoxChoiceView.swift
//  Packy
//
//  Created Mason Kim on 1/14/24.
//

import SwiftUI
import ComposableArchitecture
import Kingfisher

// MARK: - View

struct BoxChoiceView: View {
    private let store: StoreOf<BoxChoiceFeature>
    @ObservedObject private var viewStore: ViewStoreOf<BoxChoiceFeature>

    init(store: StoreOf<BoxChoiceFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        let isWiderThan375pt = UIScreen.main.isWiderThan375pt
        VStack(spacing: 0) {
            if viewStore.isPresentingFinishedMotionView {
                finishedBoxMotionView
            } else {
                NavigationBar.backAndCloseButton(
                    backButtonAction: {
                        viewStore.send(.backButtonTapped)
                    },
                    closeButtonAction: {
                        viewStore.send(.closeButtonTapped)
                    }
                )
                .padding(.top, 8)

                Text("마음에 드는 선물박스를\n골라주세요")
                    .packyFont(.heading1)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.gray900)
                    .padding(.top, isWiderThan375pt ? 48 : 30)

                VStack(spacing: isWiderThan375pt ? 80 : 64) {
                    if let selectedBox = viewStore.selectedBox {
                        // TODO: 사이즈 변경 대응
                        let frameWidth: CGFloat = isWiderThan375pt ? 220 : 180

                        ZStack {
                            NetworkImage(url: selectedBox.boxBottomUrl, contentMode: .fit)
                                .offset(x: -20, y: 20)

                            NetworkImage(url: selectedBox.boxFullUrl, contentMode: .fit)
                                .offset(x: 20, y: -20)

                        }
                        .transition(.slide)
                        .animation(nil, value: viewStore.selectedBox)
                        .frame(width: frameWidth, height: frameWidth)

                        ScrollView(.horizontal) {
                            HStack(spacing: 12) {
                                ForEach(viewStore.boxDesigns, id: \.id) { boxDesign in
                                    NetworkImage(url: boxDesign.boxFullUrl, contentMode: .fit)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .frame(width: 64, height: 64)
                                        .bouncyTapGesture {
                                            viewStore.send(.selectBox(boxDesign))
                                            HapticManager.shared.fireFeedback(.medium)
                                        }
                                }
                            }
                        }
                        .animation(.spring, value: viewStore.boxDesigns)
                        .transition(.slide)
                        .scrollIndicators(.hidden)
                        .safeAreaPadding(.horizontal, 40)
                    }
                }
                .padding(.top, isWiderThan375pt ? 60 : 48)

                Spacer()

                PackyButton(title: "다음", colorType: .black) {
                    viewStore.send(.nextButtonTapped)
                }
                .disabled(viewStore.selectedBox == nil)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
        }
        .animation(.spring, value: viewStore.isPresentingFinishedMotionView)
        .animation(.spring, value: viewStore.selectedBox)
        .navigationBarBackButtonHidden(true)
        .task {
            await viewStore
                .send(._onTask)
                .finish()
        }
    }
}

// MARK: - Inner Views

private extension BoxChoiceView {
    @ViewBuilder
    var finishedBoxMotionView: some View {
        Text("이제 선물박스를\n채우러 가볼까요?")
            .packyFont(.heading1)
            .textInteraction(initialDelay: 0.5)
            .foregroundStyle(.gray900)
            .padding(.top, 104)

        // Motion Design
        // TODO: Lottie View 띄우기
        Image(.packyLogoPurple)
            .padding(.top, 50)

        Spacer()
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
