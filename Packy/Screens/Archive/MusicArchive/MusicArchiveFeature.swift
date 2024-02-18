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

    struct State: Equatable {
        fileprivate var musicArchivePageData: [MusicArchivePageData] = []
        var isLastPage: Bool {
            musicArchivePageData.last?.last ?? true
        }

        var musics: IdentifiedArrayOf<MusicArchiveData> = []
    }

    enum Action {
        // MARK: User Action

        // MARK: Inner Business Action
        case _onTask
        case _didActiveScene
        case _fetchMoreMusics

        // MARK: Inner SetState Action
        case _setMusicPageData(MusicArchivePageData)
    }

    @Dependency(\.archiveClient) var archiveClient

    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case ._onTask:
                guard state.musicArchivePageData.isEmpty else { return .none }
                return fetchMusics(lastMusicId: nil)

            case ._didActiveScene:
                state.musicArchivePageData = []
                state.musics = []
                return fetchMusics(lastMusicId: nil)

            case let ._setMusicPageData(pageData):
                state.musicArchivePageData.append(pageData)
                state.musics.append(contentsOf: pageData.content)
                return .none

            case ._fetchMoreMusics:
                return fetchMusics(lastMusicId: state.musics.last?.id)
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
            } catch {
                print("🐛 \(error)")
            }
        }
    }
}
