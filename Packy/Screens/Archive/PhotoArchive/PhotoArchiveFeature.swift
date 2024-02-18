//
//  PhotoArchiveFeature.swift
//  Packy
//
//  Created Mason Kim on 2/18/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct PhotoArchiveFeature: Reducer {

    struct State: Equatable {
        fileprivate var photoArchivePageData: [PhotoArchivePageData] = []
        var isLastPage: Bool {
            photoArchivePageData.last?.last ?? true
        }

        var photos: IdentifiedArrayOf<PhotoArchiveData> = []
    }

    enum Action {
        // MARK: User Action

        // MARK: Inner Business Action
        case _onTask
        case _didActiveScene
        case _fetchMorePhotos

        // MARK: Inner SetState Action
        case _setPhotoPageData(PhotoArchivePageData)
    }

    @Dependency(\.archiveClient) var archiveClient

    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case ._onTask:
                guard state.photoArchivePageData.isEmpty else { return .none }
                return fetchPhotos(lastPhotoId: nil)

            case ._didActiveScene:
                state.photoArchivePageData = []
                state.photos = []
                return fetchPhotos(lastPhotoId: nil)

            case let ._setPhotoPageData(pageData):
                state.photoArchivePageData.append(pageData)
                state.photos.append(contentsOf: pageData.content)
                return .none

            case ._fetchMorePhotos:
                return fetchPhotos(lastPhotoId: state.photos.last?.id)
            }
        }
    }
}

private extension PhotoArchiveFeature {
    func fetchPhotos(lastPhotoId: Int?) -> Effect<Action> {
        .run { send in
            do {
                let response = try await archiveClient.fetchPhotos(.init(lastPhotoId: lastPhotoId))
                await send(._setPhotoPageData(response))
            } catch {
                print("🐛 \(error)")
            }
        }
    }
}
