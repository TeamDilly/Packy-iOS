//
//  RootView.swift
//  Packy
//
//  Created Mason Kim on 1/7/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct RootView: View {
    private let store: StoreOf<RootFeature>
    @ObservedObject private var viewStore: ViewStoreOf<RootFeature>

    init(store: StoreOf<RootFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        SwitchStore(store) { state in
            switch state {
            case .intro:
                CaseLet(\RootFeature.State.intro, action: RootFeature.Action.intro) { store in
                    IntroView(store: store)
                }

            case .home:
                CaseLet(\RootFeature.State.home, action: RootFeature.Action.home) { store in
                    HomeView(store: store)
                }
            }
        }
        .task {
            await viewStore
                .send(._onAppear)
                .finish()
        }
    }
}

// MARK: - Preview

#Preview {
    RootView(
        store: .init(
            initialState: .init(),
            reducer: {
                RootFeature()
                    ._printChanges()
            }
        )
    )
}
