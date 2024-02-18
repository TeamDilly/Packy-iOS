//
//  MusicArchiveView.swift
//  Packy
//
//  Created Mason Kim on 2/18/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct MusicArchiveView: View {
    private let store: StoreOf<MusicArchiveFeature>
    @ObservedObject private var viewStore: ViewStoreOf<MusicArchiveFeature>

    init(store: StoreOf<MusicArchiveFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        List {
            Text("Hello, MusicArchive!")
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
    MusicArchiveView(
        store: .init(
            initialState: .init(),
            reducer: {
                MusicArchiveFeature()
                    ._printChanges()
            }
        )
    )
}
