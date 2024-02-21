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
            IfLetStore(store.scope(state: \.$boxShare, action: \.boxShare)) { store in
                BoxShareView(store: store)
            } else: {
                boxAddTitleView
            }
            .animation(.spring, value: viewStore.boxShare == nil)
        }
        .showLoading(viewStore.isLoading)
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
    @ViewBuilder
    var boxAddTitleView: some View {
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
            throttle {
                isFocused = false
                viewStore.send(.nextButtonTapped)
            }
        }
        .buttonStyle(PackyButtonStyle(colorType: .black))
        .disabled(viewStore.boxNameInput.isEmpty)
        .animation(.spring, value: viewStore.boxNameInput)
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }
}

// MARK: - Preview

#Preview {
    BoxAddTitleAndShareView(
        store: .init(
            initialState: .init(giftBoxData: .mock, boxDesign: .mock, boxNameInput: "hello"),
            reducer: {
                BoxAddTitleAndShareFeature()
                    ._printChanges()
            }
        )
    )
    .globalLoading()
}
