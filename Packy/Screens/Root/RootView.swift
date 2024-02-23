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

    init(store: StoreOf<RootFeature>) {
        self.store = store
    }

    var body: some View {
        Group {
            switch store.state {
            case .intro:
                if let store = store.scope(state: \.intro, action: \.intro) {
                    IntroView(store: store)
                }
                
            case .mainTab:
                if let store = store.scope(state: \.mainTab, action: \.mainTab) {
                    MainTabView(store: store)
                }
            }
        }
        .animation(.spring, value: store.state)
        .task {
            await store
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
