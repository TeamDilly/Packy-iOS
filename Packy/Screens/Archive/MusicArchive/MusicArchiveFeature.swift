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

    enum Action {
        // MARK: User Action
        case musicTapped(MusicArchiveData)
        case didRefresh

        // MARK: Inner Business Action
        case _onTask
        case _fetchMoreMusics
        case _didActiveScene

        // MARK: Inner SetState Action
        case _setMusicPageData(MusicArchivePageData)
        case _setLoading(Bool)
    }

    @Dependency(\.archiveClient) var archiveClient
    @Dependency(\.continuousClock) var clock

    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case let .musicTapped(music):
                state.selectedMusic = music
                return .none

            case ._onTask:
                guard state.musicArchivePageData.isEmpty else { return .none }
                return fetchMusics(lastMusicId: nil)

            case .didRefresh, ._didActiveScene:
                state.musicArchivePageData = []
                state.musics = []
                state.isLoading = true
                return fetchMusics(lastMusicId: nil)

            case let ._setMusicPageData(pageData):
                state.musicArchivePageData.append(pageData)
                state.musics.append(contentsOf: pageData.content)
                return .none

            case ._fetchMoreMusics:
                return fetchMusics(lastMusicId: state.musics.last?.id)

            case let ._setLoading(isLoading):
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
                await send(._setMusicPageData(response), animation: .spring)

                try? await clock.sleep(for: .seconds(0.3))
                await send(._setLoading(false))
            } catch {
                print("🐛 \(error)")
                await send(._setLoading(false))
            }
        }
    }
}
