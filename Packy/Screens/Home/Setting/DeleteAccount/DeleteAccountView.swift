//
//  DeleteAccountView.swift
//  Packy
//
//  Created Mason Kim on 2/4/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct DeleteAccountView: View {
    private let store: StoreOf<DeleteAccountFeature>
    @ObservedObject private var viewStore: ViewStoreOf<DeleteAccountFeature>

    init(store: StoreOf<DeleteAccountFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        List {
            Text("Hello, DeleteAccount!")
        }
        .navigationBarBackButtonHidden(true)
        .task {
            await viewStore
                .send(._onTask)
                .finish()
        }
    }
}

// MARK: - Preview

#Preview {
    DeleteAccountView(
        store: .init(
            initialState: .init(),
            reducer: {
                DeleteAccountFeature()
                    ._printChanges()
            }
        )
    )
}
