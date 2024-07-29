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

    enum Action: ViewAction {
        case view(View)

        case setLetterPageData(LetterArchivePageData)
        case setLoading(Bool)

        enum View {
            case onTask
            case fetchMoreLetters
            case didActiveScene
            case letterTapped(LetterArchiveData)
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
                case let .letterTapped(letter):
                    state.selectedLetter = letter
                    return .none
                    
                case .onTask:
                    return fetchLetters(lastLetterId: nil)
                    
                case .didRefresh, .didActiveScene:
                    state.letterArchivePageData = []
                    state.letters = []
                    state.isLoading = true
                    return fetchLetters(lastLetterId: nil)

                case .fetchMoreLetters:
                    return fetchLetters(lastLetterId: state.letters.last?.id)
                }

            case let .setLetterPageData(pageData):
                state.letterArchivePageData.append(pageData)
                state.letters.append(contentsOf: pageData.content)
                return .none

            case let .setLoading(isLoading):
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
                await send(.setLetterPageData(response), animation: .spring)

                try? await clock.sleep(for: .seconds(0.3))
                await send(.setLoading(false))
            } catch {
                print("🐛 \(error)")
                await send(.setLoading(false))
            }
        }
    }
}
