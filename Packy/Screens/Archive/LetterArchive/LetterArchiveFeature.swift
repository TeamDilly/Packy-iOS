//
//  LetterArchiveFeature.swift
//  Packy
//
//  Created Mason Kim on 2/18/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct LetterArchiveFeature: Reducer {

    struct State: Equatable {
        fileprivate var letterArchivePageData: [LetterArchivePageData] = []
        var isLastPage: Bool {
            letterArchivePageData.last?.last ?? true
        }

        var letters: IdentifiedArrayOf<LetterArchiveData> = []
    }

    enum Action {
        // MARK: User Action

        // MARK: Inner Business Action
        case _onTask
        case _didActiveScene
        case _fetchMoreLetters

        // MARK: Inner SetState Action
        case _setLetterPageData(LetterArchivePageData)
    }

    @Dependency(\.archiveClient) var archiveClient

    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case ._onTask:
                guard state.letterArchivePageData.isEmpty else { return .none }
                return fetchLetters(lastLetterId: nil)

            case ._didActiveScene:
                state.letterArchivePageData = []
                state.letters = []
                return fetchLetters(lastLetterId: nil)

            case let ._setLetterPageData(pageData):
                state.letterArchivePageData.append(pageData)
                state.letters.append(contentsOf: pageData.content)
                return .none

            case ._fetchMoreLetters:
                return fetchLetters(lastLetterId: state.letters.last?.id)
            }
        }
    }
}

private extension LetterArchiveFeature {
    func fetchLetters(lastLetterId: Int?) -> Effect<Action> {
        .run { send in
            do {
                let response = try await archiveClient.fetchLetters(lastLetterId)
                await send(._setLetterPageData(response), animation: .spring)
            } catch {
                print("🐛 \(error)")
            }
        }
    }
}
