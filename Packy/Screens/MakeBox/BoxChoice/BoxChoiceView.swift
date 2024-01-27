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
        VStack(spacing: 0) {
            if viewStore.isPresentingFinishedMotionView {
                finishedBoxMotionView
            } else {
                NavigationBar.backAndCloseButton(closeButtonAction: {
                    viewStore.send(.closeButtonTapped)
                })
                .padding(.top, 8)

                Text("마음에 드는 선물박스를 골라주세요")
                    .packyFont(.heading1)
                    .foregroundStyle(.gray900)
                    .padding(.vertical, UIScreen.main.isWiderThan375pt ? 48 : 30)

                VStack(spacing: 40) {
                    if let selectedBox = viewStore.selectedBox {
                        NetworkImage(url: selectedBox.boxFullUrl, contentMode: .fit)
                            .frame(width: 250, height: 250)
                            .animation(nil, value: viewStore.selectedBox)
                    }
                
                    HStack(spacing: 12) {
                        ForEach(viewStore.boxDesigns, id: \.id) { boxDesign in
                            Button {
                                viewStore.send(.selectBox(boxDesign))
                                HapticManager.shared.fireFeedback(.medium)
                            } label: {
                                NetworkImage(url: boxDesign.boxFullUrl, contentMode: .fit)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.bouncy)
                        }
                    }
                    .padding(.horizontal, 40)
                }
                .padding(.top, UIScreen.main.isWiderThan375pt ? 48 : 20)

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
        // TODO: Text Interaction 구현
        Text("이제 선물박스를\n채우러 가볼까요?")
            .packyFont(.heading1)
            .foregroundStyle(.gray900)
            .padding(.top, 104)

        // Motion Design
        Image(.mock)
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
