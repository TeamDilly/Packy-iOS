//
//  BoxAddTitleView.swift
//  Packy
//
//  Created Mason Kim on 1/27/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct BoxAddTitleView: View {
    private let store: StoreOf<BoxAddTitleFeature>
    @ObservedObject private var viewStore: ViewStoreOf<BoxAddTitleFeature>
    @FocusState private var isFocused: Bool

    init(store: StoreOf<BoxAddTitleFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        VStack(spacing: 0) {
            if viewStore.showingState != .addTitle {
                boxFinalDoneAndShareView
            } else {
                NavigationBar.onlyBackButton()

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

                PackyTextField(text: viewStore.$textInput, placeholder: "12자 이내로 입력해주세요")
                    .limitTextLength(text: viewStore.$textInput, length: 12)
                    .padding(.horizontal, 24)
                    .padding(.top, 40)
                    .focused($isFocused)

                Spacer()

                Button("다음") {
                    viewStore.send(.nextButtonTapped)
                }
                .buttonStyle(PackyButtonStyle(colorType: .black))
                .disabled(viewStore.textInput.isEmpty)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
        }
        .onAppear {
            isFocused = true
        }
        .task {
            await viewStore
                .send(._onTask)
                .finish()
        }
    }
}

// MARK: - Inner Views

private extension BoxAddTitleView {
    var boxFinalDoneAndShareView: some View {
        VStack(spacing: 0) {
            Spacer()

            let isSendState = viewStore.showingState == .send

            let title = if isSendState {
                "\(viewStore.giftBox.receiverName)님에게\n선물박스를 보내보세요"
            } else {
                "\(viewStore.giftBox.receiverName)님을 위한\n선물박스가 완성되었어요!"
            }

            Text(title)
                .packyFont(.heading1)
                .foregroundStyle(.gray900)
                .padding(.top, 24)
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
                EmptyView()
                    .frame(height: 46)
            }

            Spacer()

            // TODO: Shake Animation!
            NetworkImage(url: viewStore.boxDesign.boxFullUrl)
                .frame(width: 240, height: 240)
                .padding(.bottom, 20)

            Spacer()
            Spacer()

            if isSendState {
                VStack(spacing: 8) {
                    PackyButton(title: "카카오톡으로 보내기", colorType: .black) {

                    }
                    .padding(.horizontal, 24)

                    Button("나중에 보낼래요") {

                    }
                    .buttonStyle(.text)
                    .frame(width: 129, height: 34)
                    .border(Color.black)
                }
                .frame(height: 100)
                .padding(.bottom, 20)
            } else {
                EmptyView()
                    .frame(height: 100)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    BoxAddTitleView(
        store: .init(
            initialState: .init(giftBox: .mock, boxDesign: .mock),
            reducer: {
                BoxAddTitleFeature()
                    ._printChanges()
            }
        )
    )
}
