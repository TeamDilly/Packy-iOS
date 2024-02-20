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
        @BindingState var selectedPhoto: PhotoArchiveData?

        var isLoading: Bool = false
    }

    enum Action {
        // MARK: User Action
        case photoTapped(PhotoArchiveData)
        case didRefresh

        // MARK: Inner Business Action
        case _onTask
        case _fetchMorePhotos

        // MARK: Inner SetState Action
        case _setPhotoPageData(PhotoArchivePageData)
        case _setLoading(Bool)
    }

    @Dependency(\.archiveClient) var archiveClient

    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case let .photoTapped(photo):
                state.selectedPhoto = photo
                return .none
                
            case ._onTask:
                guard state.photoArchivePageData.isEmpty else { return .none }
                return fetchPhotos(lastPhotoId: nil)

            case .didRefresh:
                state.photoArchivePageData = []
                state.photos = []
                return fetchPhotos(lastPhotoId: nil)

            case let ._setPhotoPageData(pageData):
                state.photoArchivePageData.append(pageData)
                state.photos.append(contentsOf: pageData.content)
                return .none

            case ._fetchMorePhotos:
                return fetchPhotos(lastPhotoId: state.photos.last?.id)

            case let ._setLoading(isLoading):
                state.isLoading = isLoading
                return .none
            }
        }
    }
}

private extension PhotoArchiveFeature {
    func fetchPhotos(lastPhotoId: Int?) -> Effect<Action> {
        .run { send in
            await send(._setLoading(true))
            do {
                let response = try await archiveClient.fetchPhotos(lastPhotoId)
                await send(._setPhotoPageData(response), animation: .spring)
                await send(._setLoading(false))
            } catch {
                print("🐛 \(error)")
            }
        }
    }
}
