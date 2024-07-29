//
//  MusicArchiveView.swift
//  Packy
//
//  Created Mason Kim on 2/18/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

@ViewAction(for: MusicArchiveFeature.self)
struct MusicArchiveView: View {
    let store: StoreOf<MusicArchiveFeature>
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        VStack {
            if store.musics.isEmpty && !store.isLoading {
                Text("아직 선물받은 음악이 없어요")
                    .packyFont(.body2)
                    .foregroundStyle(.gray600)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.bottom, 50)
            } else {
                StaggeredGrid(columns: 2, data: store.musics.elements) { music in
                    MusicCell(youtubeUrl: music.youtubeUrl)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            HapticManager.shared.fireFeedback(.soft)
                            send(.musicTapped(music))
                        }
                        .onAppear {
                            // Pagination
                            guard store.isLastPage == false,
                                  let index = store.musics.firstIndex(of: music) else { return }

                            let isNearEndForNextPageLoad = index == store.musics.endIndex - 3
                            guard isNearEndForNextPageLoad else { return }
                            print("🐛 fetch more musics")
                            send(.fetchMoreMusics)
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
            await send(.didRefresh).finish()
        }
        .task {
            await send(.onTask).finish()
        }
        .onChange(of: scenePhase) {
            guard $1 == .active else { return }
            send(.didActiveScene)
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
