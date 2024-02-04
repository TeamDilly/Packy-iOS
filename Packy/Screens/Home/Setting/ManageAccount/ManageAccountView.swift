//
//  ManageAccountView.swift
//  Packy
//
//  Created Mason Kim on 2/4/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct ManageAccountView: View {
    private let store: StoreOf<ManageAccountFeature>
    @ObservedObject private var viewStore: ViewStoreOf<ManageAccountFeature>

    init(store: StoreOf<ManageAccountFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        List {
            Text("Hello, ManageAccount!")
            TextField("Binding Text", text: viewStore.$textInput)
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
    ManageAccountView(
        store: .init(
            initialState: .init(),
            reducer: {
                ManageAccountFeature()
                    ._printChanges()
            }
        )
    )
}
