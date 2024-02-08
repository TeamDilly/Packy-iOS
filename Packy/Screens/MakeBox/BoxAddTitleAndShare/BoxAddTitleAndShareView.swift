//
//  BoxAddTitleAndShareView.swift
//  Packy
//
//  Created Mason Kim on 1/27/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct BoxAddTitleAndShareView: View {
    private let store: StoreOf<BoxAddTitleAndShareFeature>
    @ObservedObject private var viewStore: ViewStoreOf<BoxAddTitleAndShareFeature>
    @FocusState private var isFocused: Bool

    init(store: StoreOf<BoxAddTitleAndShareFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        VStack(spacing: 0) {
            if viewStore.showingState != .addTitle {
                boxFinalDoneAndShareView
            } else {
                NavigationBar.onlyBackButton {
                    viewStore.send(.backButtonTapped)
                }

                Text("마지막으로 선물박스에\n이름을 붙여주세요")
                    .packyFont(.heading1)
                    .foregroundStyle(.gray900)
                    .padding(.top, 24)
                    .multilineTextAlignment(.center)

                Text("선물박스의 이름을 붙여 특별함을 더해요\n붙인 이름은 받는 분에게도 보여져요")
                    .packyFont(.body4)
                    .foregroundStyle(.gray600)
                    .padding(.top, 8)
                    .multilineTextAlignment(.center)

                PackyTextField(text: viewStore.$boxNameInput, placeholder: "12자 이내로 입력해주세요")
                    .focused($isFocused)
                    .limitTextLength(text: viewStore.$boxNameInput, length: 12)
                    .padding(.horizontal, 24)
                    .padding(.top, 40)

                Spacer()

                Button("다음") {
                    isFocused = false
                    viewStore.send(.nextButtonTapped)
                }
                .buttonStyle(PackyButtonStyle(colorType: .black))
                .disabled(viewStore.boxNameInput.isEmpty)
                .animation(.spring, value: viewStore.boxNameInput)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
        }
        .popGestureDisabled()
        .makeTapToHideKeyboard()
        .navigationBarBackButtonHidden(true)
        .task {
            await viewStore
                .send(._onTask)
                .finish()

            isFocused = true
        }
        .onDisappear(perform: {
            print("disappear???")
        })
    }
}

// MARK: - Inner Views

private extension BoxAddTitleAndShareView {
    var boxFinalDoneAndShareView: some View {
        let isSendState = viewStore.showingState == .send

        return VStack(spacing: 0) {
            NavigationBar(rightIcon: isSendState ? Image(.xmark) : nil) {
                viewStore.send(.closeButtonTapped)
            }

            Spacer()

            Group {
                if isSendState {
                    Text("\(viewStore.giftBox.receiverName)님에게\n선물박스를 보내보세요")
                } else {
                    Text("\(viewStore.giftBox.receiverName)님을 위한\n선물박스가 완성되었어요!")
                        .textInteraction()
                }
            }
            .packyFont(.heading1)
            .foregroundStyle(.gray900)
            .padding(.top, -24)
            .multilineTextAlignment(.center)

            if isSendState {
                Text(viewStore.giftBox.name)
                    .packyFont(.body4)
                    .foregroundStyle(.gray900)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(
                        Capsule()
                            .fill(.gray100)
                            .stroke(.gray300, style: .init())
                    )
                    .padding(.top, 20)
            } else {
                Spacer()
                    .frame(height: 46)
                    .padding(.top, 20)
            }

            Spacer()

            NetworkImage(url: viewStore.boxDesign.boxSetUrl, contentMode: .fit)
                .shakeRepeat(.veryWeak)
                .aspectRatio(contentMode: .fit)
                .padding(.horizontal, 80)
                .padding(.bottom, 20)

            Spacer()

            if isSendState {
                VStack(spacing: 8) {
                    PackyButton(title: "카카오톡으로 보내기", colorType: .black) {
                        viewStore.send(.sendButtonTapped)
                    }
                    .padding(.horizontal, 24)

                    // TODO: 차후 - 나중에 보내기 시 선물함 페이지로 이동?
                    // Button("나중에 보낼래요") {
                    // 
                    // }
                    // .buttonStyle(.text)
                    // .frame(width: 129, height: 34)
                }
                .frame(height: 100)
                .padding(.bottom, 20)
            } else {
                Spacer()
                    .frame(height: 100)
                    .padding(.bottom, 20)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    BoxAddTitleAndShareView(
        store: .init(
            initialState: .init(giftBox: .mock, boxDesign: .mock, boxNameInput: "hello", showingState: .send),
            reducer: {
                BoxAddTitleAndShareFeature()
                    ._printChanges()
            }
        )
    )
}
