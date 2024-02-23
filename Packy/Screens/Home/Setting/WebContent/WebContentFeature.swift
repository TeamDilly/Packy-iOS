//
//  WebContentFeature.swift
//  Packy
//
//  Created Mason Kim on 2/5/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct WebContentFeature: Reducer {

    @ObservableState
    struct State: Equatable {
        var urlString: String
        var navigationTitle: String

        init(urlString: String, navigationTitle: String) {
            self.urlString = urlString
            self.navigationTitle = navigationTitle
        }
    }

    enum Action {
        case _onTask
        case backButtonTapped
    }

    @Dependency(\.dismiss) var dismiss

    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case ._onTask:
                return .none
            case .backButtonTapped:
                return .run { _ in
                    await dismiss()
                }
            }
        }
    }
}
