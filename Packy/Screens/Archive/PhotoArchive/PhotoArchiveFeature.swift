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

    @ObservableState
    struct State: Equatable {
        fileprivate var photoArchivePageData: [PhotoArchivePageData] = []
        var isLastPage: Bool {
            photoArchivePageData.last?.last ?? true
        }

        var photos: IdentifiedArrayOf<PhotoArchiveData> = []
        var selectedPhoto: PhotoArchiveData?

        var isLoading: Bool = true
    }

    enum Action: ViewAction {
        case view(View)

        case setPhotoPageData(PhotoArchivePageData)
        case setLoading(Bool)

        enum View {
            case onTask
            case didActiveScene
            case didRefresh
            case photoTapped(PhotoArchiveData)
            case fetchMorePhotos
        }
    }

    @Dependency(\.archiveClient) var archiveClient
    @Dependency(\.continuousClock) var clock

    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case let .view(action):
                switch action {
                case let .photoTapped(photo):
                    state.selectedPhoto = photo
                    return .none

                case .onTask:
                    return fetchPhotos(lastPhotoId: nil)

                case .didRefresh, .didActiveScene:
                    state.photoArchivePageData = []
                    state.photos = []
                    state.isLoading = true
                    return fetchPhotos(lastPhotoId: nil)

                case .fetchMorePhotos:
                    return fetchPhotos(lastPhotoId: state.photos.last?.id)
                }

            case let .setPhotoPageData(pageData):
                state.photoArchivePageData.append(pageData)
                state.photos.append(contentsOf: pageData.content)
                return .none

            case let .setLoading(isLoading):
                state.isLoading = isLoading
                return .none
            }
        }
    }
}

private extension PhotoArchiveFeature {
    func fetchPhotos(lastPhotoId: Int?) -> Effect<Action> {
        .run { send in
            do {
                let response = try await archiveClient.fetchPhotos(lastPhotoId)
                await send(.setPhotoPageData(response), animation: .spring)

                try? await clock.sleep(for: .seconds(0.3))
                await send(.setLoading(false))
            } catch {
                print("🐛 \(error)")
                await send(.setLoading(false))
            }
        }
    }
}
