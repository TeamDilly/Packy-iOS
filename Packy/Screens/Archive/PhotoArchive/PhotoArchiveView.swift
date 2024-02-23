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
    @Environment(\.scenePhase) private var scenePhase
    @State private var columns: Int = 2

    init(store: StoreOf<PhotoArchiveFeature>) {
        self.store = store
    }

    var body: some View {
        VStack {
            if store.photos.isEmpty && !store.isLoading {
                Text("아직 선물받은 사진이 없어요")
                    .packyFont(.body2)
                    .foregroundStyle(.gray600)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.bottom, 50)
            } else {
                StaggeredGrid(columns: columns, data: store.photos.elements) { photo in
                    PhotoCell(photoUrl: photo.photoUrl)
                        .onTapGesture {
                            HapticManager.shared.fireFeedback(.soft)
                            store.send(.photoTapped(photo))
                        }
                        .onAppear {
                            // Pagination
                            guard store.isLastPage == false,
                                  let index = store.photos.firstIndex(of: photo) else { return }

                            let isNearEndForNextPageLoad = index == store.photos.endIndex - 3
                            guard isNearEndForNextPageLoad else { return }
                            store.send(._fetchMorePhotos)
                        }
                }
                .zigzagPadding(80)
                .innerSpacing(vertical: 32, horizontal: 16)
                .transition(.opacity)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 24)
        .background(.gray100)
        .refreshable {
            await store
                .send(.didRefresh)
                .finish()
        }
        .didLoad {
            await store
                .send(._onTask)
                .finish()
        }
        .onChange(of: scenePhase) {
            guard $1 == .active else { return }
            store.send(._didActiveScene)
        }
    }
}

// MARK: - Inner Views

private struct PhotoCell: View {
    var photoUrl: String

    var body: some View {
        NetworkImage(url: photoUrl)
            .aspectRatio(1, contentMode: .fit)
            .padding(.horizontal, 8)
            .padding(.top, 8)
            .padding(.bottom, 40)
            .background(.white)
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
