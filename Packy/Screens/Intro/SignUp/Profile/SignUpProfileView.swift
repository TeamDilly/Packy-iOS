//
//  SignUpProfileView.swift
//  Packy
//
//  Created Mason Kim on 1/9/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct SignUpProfileView: View {
    private let store: StoreOf<SignUpProfileFeature>
    @ObservedObject private var viewStore: ViewStoreOf<SignUpProfileFeature>

    init(store: StoreOf<SignUpProfileFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        List {
            Text("Hello, SignUpProfile!")
            TextField("Binding Text", text: viewStore.$textInput)
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
    SignUpProfileView(
        store: .init(
            initialState: .init(),
            reducer: {
                SignUpProfileFeature()
                    ._printChanges()
            }
        )
    )
}
