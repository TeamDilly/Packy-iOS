//
//  MakeBoxFeature+Navigation.swift
//  Packy
//
//  Created Mason Kim on 1/14/24.
//

import ComposableArchitecture

// MARK: - Navigation Path

@Reducer
struct MakeBoxNavigationPath {
    enum State: Equatable {
        case boxChoice(BoxChoiceFeature.State)
        case startGuide(BoxStartGuideFeature.State)
        case addTitle(BoxAddTitleFeature.State)
    }

    enum Action {
        case boxChoice(BoxChoiceFeature.Action)
        case startGuide(BoxStartGuideFeature.Action)
        case addTitle(BoxAddTitleFeature.Action)
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.boxChoice, action: \.boxChoice) { BoxChoiceFeature() }
        Scope(state: \.startGuide, action: \.startGuide) { BoxStartGuideFeature() }
        Scope(state: \.addTitle, action: \.addTitle) { BoxAddTitleFeature() }
    }
}

// MARK: - Navigation Reducer

extension MakeBoxFeature {
    var navigationReducer: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .path(action):
                switch action {
                case let .element(id: _, action: .boxChoice(.delegate(.moveToBoxStartGuide(data)))):
                    state.path.append(.startGuide(.init(senderInfo: data.senderInfo, boxDesigns: data.boxDesigns, selectedBox: data.selectedBox)))
                    return .none

                case let .element(id: _, action: .startGuide(.delegate(.moveToAddTitle(giftBox, boxDesign)))):
                    state.path.append(.addTitle(.init(giftBox: giftBox, boxDesign: boxDesign)))
                    return .none

                case .element:
                    return .none

                default:
                    return .none
                }

            default:
                return .none
            }
        }
        .forEach(\.path, action: /Action.path) {
            MakeBoxNavigationPath()
        }
    }
}
