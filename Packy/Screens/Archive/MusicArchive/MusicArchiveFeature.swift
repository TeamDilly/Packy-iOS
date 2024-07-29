//
//  MusicArchiveFeature.swift
//  Packy
//
//  Created Mason Kim on 2/18/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct MusicArchiveFeature: Reducer {

    @ObservableState
    struct State: Equatable {
        fileprivate var musicArchivePageData: [MusicArchivePageData] = []
        var isLastPage: Bool {
            musicArchivePageData.last?.last ?? true
        }

        var musics: IdentifiedArrayOf<MusicArchiveData> = []
        var selectedMusic: MusicArchiveData?

        var isLoading: Bool = true
    }

    enum Action: ViewAction {
        case view(View)

        case setMusicPageData(MusicArchivePageData)
        case setLoading(Bool)

        enum View {
            case onTask
            case didActiveScene
            case fetchMoreMusics
            case musicTapped(MusicArchiveData)
            case didRefresh
        }
    }

    @Dependency(\.archiveClient) var archiveClient
    @Dependency(\.continuousClock) var clock

    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case let .view(action):
                switch action {
                case let .musicTapped(music):
                    state.selectedMusic = music
                    return .none

                case .onTask:
                    return fetchMusics(lastMusicId: nil)

                case .didRefresh, .didActiveScene:
                    state.musicArchivePageData = []
                    state.musics = []
                    state.isLoading = true
                    return fetchMusics(lastMusicId: nil)

                case .fetchMoreMusics:
                    return fetchMusics(lastMusicId: state.musics.last?.id)
                }

            case let .setMusicPageData(pageData):
                state.musicArchivePageData.append(pageData)
                state.musics.append(contentsOf: pageData.content)
                return .none

            case let .setLoading(isLoading):
                state.isLoading = isLoading
                return .none
            }
        }
    }
}

private extension MusicArchiveFeature {
    func fetchMusics(lastMusicId: Int?) -> Effect<Action> {
        .run { send in
            do {
                let response = try await archiveClient.fetchMusics(lastMusicId)
                await send(.setMusicPageData(response), animation: .spring)

                try? await clock.sleep(for: .seconds(0.3))
                await send(.setLoading(false))
            } catch {
                print("🐛 \(error)")
                await send(.setLoading(false))
            }
        }
    }
}
