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

    @ObservableState
    struct State: Equatable {
        fileprivate var letterArchivePageData: [LetterArchivePageData] = []
        var isLastPage: Bool {
            letterArchivePageData.last?.last ?? true
        }

        var letters: IdentifiedArrayOf<LetterArchiveData> = []
        var selectedLetter: LetterArchiveData?

        var isLoading: Bool = true
    }

    enum Action {
        // MARK: User Action
        case letterTapped(LetterArchiveData)
        case didRefresh

        // MARK: Inner Business Action
        case _onTask
        case _fetchMoreLetters
        case _didActiveScene

        // MARK: Inner SetState Action
        case _setLetterPageData(LetterArchivePageData)
        case _setLoading(Bool)
    }

    @Dependency(\.archiveClient) var archiveClient
    @Dependency(\.continuousClock) var clock

    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case let .letterTapped(letter):
                state.selectedLetter = letter
                return .none
                
            case ._onTask:
                return fetchLetters(lastLetterId: nil)

            case .didRefresh, ._didActiveScene:
                state.letterArchivePageData = []
                state.letters = []
                state.isLoading = true
                return fetchLetters(lastLetterId: nil)

            case let ._setLetterPageData(pageData):
                state.letterArchivePageData.append(pageData)
                state.letters.append(contentsOf: pageData.content)
                return .none

            case ._fetchMoreLetters:
                return fetchLetters(lastLetterId: state.letters.last?.id)

            case let ._setLoading(isLoading):
                state.isLoading = isLoading
                return .none
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

                try? await clock.sleep(for: .seconds(0.3))
                await send(._setLoading(false))
            } catch {
                print("🐛 \(error)")
                await send(._setLoading(false))
            }
        }
    }
}
