//
//  BoxChoiceView.swift
//  Packy
//
//  Created Mason Kim on 1/14/24.
//

import SwiftUI
import ComposableArchitecture

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
                    .padding(.top, 48)

                VStack(spacing: 40) {
                    Image(.mock)
                        .resizable()
                        .frame(width: 160, height: 160)
                        .mask(Circle())

                    HStack(spacing: 12) {
                        ForEach(0...3, id: \.self) { index in
                            Button {
                                viewStore.send(.selectBox(index))
                                HapticManager.shared.fireNotification(.success)
                            } label: {
                                if let selectedBox = viewStore.selectedBox {
                                    // TODO: 선택된 박스가 존재하면....!
                                }

                                // TODO: 선택된 박스 이미지 인덱스에 따라 업뎃
                                RoundedRectangle(cornerRadius: 12)
                                    .aspectRatio(1, contentMode: .fit)

                            }
                            .buttonStyle(.bouncy)
                        }
                    }
                    .padding(.horizontal, 40)
                }
                .padding(.top, 82)

                Spacer()

                PackyButton(title: "다음", colorType: .black) {
                    viewStore.send(.nextButtonTapped)
                }
                .disabled(viewStore.selectedBox == nil)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
        }
        .packyAlert(isPresented: viewStore.$isShowAlert, title: "Title", confirm: "Confirm", confirmAction: {
            viewStore.send(.alertConfirmButtonTapped)
        })
        .animation(.spring, value: viewStore.isPresentingFinishedMotionView)
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
