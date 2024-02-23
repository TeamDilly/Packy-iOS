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
    @Environment(\.scenePhase) private var scenePhase

    init(store: StoreOf<MusicArchiveFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        VStack {
            if viewStore.musics.isEmpty && !viewStore.isLoading {
                Text("아직 선물받은 음악이 없어요")
                    .packyFont(.body2)
                    .foregroundStyle(.gray600)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.bottom, 50)
            } else {
                StaggeredGrid(columns: 2, data: viewStore.musics.elements) { music in
                    MusicCell(youtubeUrl: music.youtubeUrl)
                        .bouncyTapGesture {
                            viewStore.send(.musicTapped(music))
                        }
                        .onAppear {
                            // Pagination
                            guard viewStore.isLastPage == false,
                                  let index = viewStore.musics.firstIndex(of: music) else { return }

                            let isNearEndForNextPageLoad = index == viewStore.musics.endIndex - 3
                            guard isNearEndForNextPageLoad else { return }
                            print("🐛 fetch more musics")
                            viewStore.send(._fetchMoreMusics)
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
            await viewStore.send(.didRefresh, while: \.isLoading)
        }
        .didLoad {
            await viewStore
                .send(._onTask)
                .finish()
        }
        .onChange(of: scenePhase) {
            guard $1 == .active else { return }
            viewStore.send(._didActiveScene)
        }
    }
}

// MARK: - Inner Views

private struct MusicCell: View {
    var imageUrl: String?

    init(youtubeUrl: String) {
        if let thumbnailUrl = YoutubeThumbnailGenerator.thumbnailUrl(fromYoutubeUrl: youtubeUrl) {
            self.imageUrl = thumbnailUrl
        } else {
            imageUrl = nil
        }
    }

    var body: some View {
        NetworkImage(url: imageUrl ?? "", contentMode: .fill)
            .redacted(reason: imageUrl == nil ? .placeholder : [])
            .aspectRatio(1, contentMode: .fit)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .fill(.gray900)
                    .frame(width: 44, height: 44)
            )
            .overlay(
                Circle()
                    .fill(.gray100)
                    .frame(width: 10, height: 10)
            )
    }
}


// MARK: - Preview

#Preview {
    MusicArchiveView(
        store: .init(
            initialState: .init(),
            reducer: {
                MusicArchiveFeature()
                    // ._printChanges()
            }
        )
    )
}
