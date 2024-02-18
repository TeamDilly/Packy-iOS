//
//  GiftArchiveView.swift
//  Packy
//
//  Created Mason Kim on 2/18/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct GiftArchiveView: View {
    private let store: StoreOf<GiftArchiveFeature>
    @ObservedObject private var viewStore: ViewStoreOf<GiftArchiveFeature>

    init(store: StoreOf<GiftArchiveFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        List {
            Text("Hello, GiftArchive!")
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
    GiftArchiveView(
        store: .init(
            initialState: .init(),
            reducer: {
                GiftArchiveFeature()
                    ._printChanges()
            }
        )
    )
}
