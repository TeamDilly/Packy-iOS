//
//  BoxAddInfoView.swift
//  Packy
//
//  Created Mason Kim on 1/14/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct BoxAddInfoView: View {
    private let store: StoreOf<BoxAddInfoFeature>
    @ObservedObject private var viewStore: ViewStoreOf<BoxAddInfoFeature>

    init(store: StoreOf<BoxAddInfoFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        VStack(spacing: 0) {
            NavigationBar.onlyBackButton {
                viewStore.send(.backButtonTapped)
            }
            .padding(.bottom, 66)

            Text("패키와 함께 마음을 담은\n선물박스를 만들어볼까요?")
                .packyFont(.heading1)
                .foregroundStyle(.gray900)
                .multilineTextAlignment(.center)
                .padding(.bottom, 8)
                .padding(.horizontal, 24)

            Text("보내는 사람과 받는 사람의 이름을 적어주세요")
                .packyFont(.body4)
                .foregroundStyle(.gray600)
                .padding(.bottom, 40)
                .padding(.horizontal, 24)

            ToFromInputTextField(
                to: viewStore.$boxSendTo,
                from: viewStore.$boxSendFrom
            )
            .padding(.horizontal, 24)

            Spacer()

            let destinationState = HomeNavigationPath.State.boxChoice(
                .init(senderInfo: .init(receiver: viewStore.boxSendTo, sender: viewStore.boxSendFrom))
            )

            NavigationLink("다음", state: destinationState)
                .buttonStyle(PackyButtonStyle(colorType: .black))
                .padding(.bottom, 16)
                .padding(.horizontal, 24)
                .disabled(!viewStore.nextButtonEnabled)
                .animation(.spring, value: viewStore.nextButtonEnabled)
        }
        .navigationBarBackButtonHidden(true)
        .task {
            await viewStore
                .send(._onTask)
                .finish()
        }
    }
}

// MARK: - Inner Views

private struct ToFromInputTextField: View {
    @Binding var to: String
    @Binding var from: String

    @FocusState private var toFieldFocused: Bool
    @FocusState private var fromFieldFocused: Bool

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 16) {
                let textWidth = proxy.size.width / 3

                let prompt = Text("6자까지 입력할 수 있어요")
                    .foregroundStyle(.gray400)
                    .font(.packy(.body4))

                HStack {
                    Text("To.")
                        .packyFont(.body2)
                        .foregroundStyle(.gray900)
                        .frame(width: textWidth, alignment: .leading)

                    TextField("", text: $to, prompt: prompt)
                        .tint(.black)
                        .packyFont(.body4)
                        .truncationMode(.head)
                        .multilineTextAlignment(.trailing)
                        .limitTextLength(text: $to, length: 6)
                        .frame(height: 26)
                        .focused($toFieldFocused)
                        .onSubmit {
                            guard from.isEmpty else { return }
                            fromFieldFocused = true
                        }
                }
                .onTapGesture {
                    toFieldFocused = true
                }

                Line()
                    .stroke(style: .init(dash: [7]))
                    .foregroundStyle(.gray400)
                    .frame(height: 1)

                HStack {
                    Text("From.")
                        .packyFont(.body2)
                        .foregroundStyle(.gray900)
                        .frame(width: textWidth, alignment: .leading)
                    TextField("", text: $from, prompt: prompt)
                        .tint(.black)
                        .packyFont(.body4)
                        .truncationMode(.head)
                        .multilineTextAlignment(.trailing)
                        .limitTextLength(text: $from, length: 6)
                        .frame(height: 26)
                        .focused($fromFieldFocused)
                }
                .onTapGesture {
                    fromFieldFocused = true
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.gray100)
            )
        }
        .onAppear {
            toFieldFocused = true
        }
    }
}

// MARK: - Preview

#Preview {
    BoxAddInfoView(
        store: .init(
            initialState: BoxAddInfoFeature.State(),
            reducer: {
                BoxAddInfoFeature()
                    ._printChanges()
            }
        )
    )
}
