//
//  SplashView.swift
//  Packy
//
//  Created Mason Kim on 2/5/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct SplashView: View {
    private let store: StoreOf<SplashFeature>
    @ObservedObject private var viewStore: ViewStoreOf<SplashFeature>

    init(store: StoreOf<SplashFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        VStack {
            Image(.logoLarge)
                .offset(y: -12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.purple500)
        .task {
            await viewStore
                .send(._onTask)
                .finish()
        }
    }
}

// MARK: - Preview

#Preview {
    SplashView(
        store: .init(
            initialState: .init(),
            reducer: {
                SplashFeature()
                    ._printChanges()
            }
        )
    )
}
