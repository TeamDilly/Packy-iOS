//
//  LetterArchiveView.swift
//  Packy
//
//  Created Mason Kim on 2/18/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct LetterArchiveView: View {
    private let store: StoreOf<LetterArchiveFeature>
    @ObservedObject private var viewStore: ViewStoreOf<LetterArchiveFeature>

    init(store: StoreOf<LetterArchiveFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        List {
            Text("Hello, LetterArchive!")
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
    LetterArchiveView(
        store: .init(
            initialState: .init(),
            reducer: {
                LetterArchiveFeature()
                    ._printChanges()
            }
        )
    )
}
