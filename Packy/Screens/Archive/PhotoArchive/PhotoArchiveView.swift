//
//  PhotoArchiveView.swift
//  Packy
//
//  Created Mason Kim on 2/18/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct PhotoArchiveView: View {
    private let store: StoreOf<PhotoArchiveFeature>
    @ObservedObject private var viewStore: ViewStoreOf<PhotoArchiveFeature>

    init(store: StoreOf<PhotoArchiveFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        VStack {
            StaggeredGrid(columns: 2, data: viewStore.photos) { photo in
                NetworkImage(url: photo.photoUrl)
                    .aspectRatio(1, contentMode: .fit)
                    .padding(.horizontal, 8)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                    .background(.white)
            }
            .zigzagPadding(80)
            .innerSpacing(vertical: 32, horizontal: 16)
        }
        .padding(.horizontal, 24)
        .background(.gray100)
        .task {
            await viewStore
                .send(._onTask)
                .finish()
        }
    }
}

// MARK: - Preview

#Preview {
    PhotoArchiveView(
        store: .init(
            initialState: .init(),
            reducer: {
                PhotoArchiveFeature()
                    ._printChanges()
            }
        )
    )
}
