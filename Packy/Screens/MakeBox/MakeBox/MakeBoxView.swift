//
//  MakeBoxView.swift
//  Packy
//
//  Created Mason Kim on 1/14/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct MakeBoxView: View {
    private let store: StoreOf<MakeBoxFeature>
    @ObservedObject private var viewStore: ViewStoreOf<MakeBoxFeature>

    init(store: StoreOf<MakeBoxFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        NavigationStackStore(store.scope(state: \.path, action: \.path)) {
            content
        } destination: { state in
            switch state {
            case .boxChoice:
                CaseLet(
                    \MakeBoxNavigationPath.State.boxChoice,
                     action: MakeBoxNavigationPath.Action.boxChoice,
                     then: BoxChoiceView.init
                )

            case .startGuide:
                CaseLet(
                    \MakeBoxNavigationPath.State.startGuide,
                     action: MakeBoxNavigationPath.Action.startGuide,
                     then: BoxStartGuideView.init
                )
            }
        }
    }
}

// MARK: - Inner Views

private extension MakeBoxView {

    var content: some View {
        VStack(spacing: 0) {
            NavigationBar.onlyBackButton {

            }
            .padding(.bottom, 66)

            Text("패키와 함께 마음을 담은\n선물박스를 만들어볼까요?")
                .packyFont(.heading1)
                .foregroundStyle(.gray900)
                .padding(.bottom, 8)

            Text("보내는 사람과 받는 사람의 이름을 적어주세요")
                .packyFont(.body4)
                .foregroundStyle(.gray600)
                .padding(.bottom, 40)

            toFromInputTextField

            Spacer()

            let destinationState = MakeBoxNavigationPath.State.boxChoice(
                .init(senderInfo: .init(to: viewStore.boxSendTo, from: viewStore.boxSendFrom))
            )

            NavigationLink("다음", state: destinationState)
                .buttonStyle(PackyButtonStyle(colorType: .black))
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
        }
        .task {
            await viewStore
                .send(._onTask)
                .finish()
        }
    }
}

// MARK: - Inner Views

private extension MakeBoxView {
    var toFromInputTextField: some View {
        GeometryReader { proxy in
            VStack(spacing: 16) {
                let halfWidth = proxy.size.width / 2

                let prompt = Text("6자 이내로 입력해주세요")
                    .foregroundStyle(.gray400)
                    .font(.packy(.body4))

                HStack {
                    Text("To.")
                        .packyFont(.body2)
                        .foregroundStyle(.gray900)
                        .frame(width: halfWidth, alignment: .leading)

                    TextField("", text: viewStore.$boxSendTo, prompt: prompt)
                        .tint(.black)
                        .packyFont(.body4)
                    // .focused($textFieldFocused)
                        .truncationMode(.head)
                        .multilineTextAlignment(.trailing)
                }

                Line()
                    .stroke(style: .init(dash: [7]))
                    .foregroundStyle(.gray400)
                    .frame(height: 1)

                HStack {
                    Text("From.")
                        .packyFont(.body2)
                        .foregroundStyle(.gray900)
                        .frame(width: halfWidth, alignment: .leading)
                    TextField("", text: viewStore.$boxSendFrom, prompt: prompt)
                        .tint(.black)
                        .packyFont(.body4)
                    // .focused($textFieldFocused)
                        .truncationMode(.head)
                        .multilineTextAlignment(.trailing)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.gray100)
            )
        }
    }
}

// MARK: - Preview

#Preview {
    MakeBoxView(
        store: .init(
            initialState: .init(),
            reducer: {
                MakeBoxFeature()
                    ._printChanges()
            }
        )
    )
}
