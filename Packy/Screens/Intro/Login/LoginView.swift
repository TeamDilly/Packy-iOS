//
//  LoginView.swift
//  Packy
//
//  Created Mason Kim on 1/7/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct LoginView: View {
    private let store: StoreOf<LoginFeature>
    @ObservedObject private var viewStore: ViewStoreOf<LoginFeature>

    init(store: StoreOf<LoginFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        List {
            Text("Hello, Login!")
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
    LoginView(
        store: .init(
            initialState: .init(),
            reducer: {
                LoginFeature()
                    ._printChanges()
            }
        )
    )
}
