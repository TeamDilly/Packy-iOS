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
                .padding(.bottom, 54)

            Image(.mock)
                .resizable()
                .frame(width: 300, height: 300)

            Spacer()

            NavigationLink(
                "선물박스 만들기",
                state: MakeBoxNavigationPath.State.startGuide()
            )
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
