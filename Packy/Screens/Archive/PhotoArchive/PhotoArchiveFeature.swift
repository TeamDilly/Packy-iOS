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
        fileprivate var photoArchivePageData: [PhotoArchivePageData] = [.mock]
        var photos: [PhotoArchiveData] {
            Set(photoArchivePageData.flatMap(\.content)).sorted(by: \.id)
        }
    }

    enum Action {
        // MARK: User Action

        // MARK: Inner Business Action
        case _onTask

        // MARK: Inner SetState Action
    }


    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case ._onTask:
                return .none
            }
        }
    }
}
