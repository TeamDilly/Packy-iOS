//
//  HomeFeature+Navigation.swift
//  Packy
//
//  Created Mason Kim on 2/4/24.
//

import ComposableArchitecture

// MARK: - Navigation Path

@Reducer
struct HomeNavigationPath {
    enum State: Equatable {
        case myBox(MyBoxFeature.State = .init())
        case boxDetail(BoxDetailFeature.State)

        case setting(SettingFeature.State = .init())
        case manageAccount(ManageAccountFeature.State = .init())
        case deleteAccount(DeleteAccountFeature.State = .init())

        case makeBox(MakeBoxFeature.State = .init())
        case boxChoice(BoxChoiceFeature.State)
        case startGuide(BoxStartGuideFeature.State)
        case addTitle(BoxAddTitleAndShareFeature.State)
    }

    enum Action {
        case myBox(MyBoxFeature.Action)
        case boxDetail(BoxDetailFeature.Action)
        case setting(SettingFeature.Action)
        case manageAccount(ManageAccountFeature.Action)
        case deleteAccount(DeleteAccountFeature.Action)

        case makeBox(MakeBoxFeature.Action)
        case boxChoice(BoxChoiceFeature.Action)
        case startGuide(BoxStartGuideFeature.Action)
        case addTitle(BoxAddTitleAndShareFeature.Action)
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.myBox, action: \.myBox) { MyBoxFeature() }
        Scope(state: \.boxDetail, action: \.boxDetail) { BoxDetailFeature() }

        Scope(state: \.setting, action: \.setting) { SettingFeature() }
        Scope(state: \.manageAccount, action: \.manageAccount) { ManageAccountFeature() }
        Scope(state: \.deleteAccount, action: \.deleteAccount) { DeleteAccountFeature() }

        Scope(state: \.makeBox, action: \.makeBox) { MakeBoxFeature() }
        Scope(state: \.boxChoice, action: \.boxChoice) { BoxChoiceFeature() }
        Scope(state: \.startGuide, action: \.startGuide) { BoxStartGuideFeature() }
        Scope(state: \.addTitle, action: \.addTitle) { BoxAddTitleAndShareFeature() }
    }
}

// MARK: - Navigation Reducer

extension HomeFeature {
    var navigationReducer: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .path(action):
                switch action {
                /// 회원탈퇴 완료 시 Stack 전부 비우기
                case .element(id: _, action: .deleteAccount(.delegate(.completedSignOut))):
                    state.path.removeAll()
                    return .none

                case let .element(id: _, action: .boxChoice(.delegate(.moveToBoxStartGuide(data)))):
                    state.path.append(.startGuide(.init(senderInfo: data.senderInfo, boxDesigns: data.boxDesigns, selectedBox: data.selectedBox)))
                    return .none

                case let .element(id: _, action: .startGuide(.delegate(.moveToAddTitle(giftBox, boxDesign)))):
                    state.path.append(.addTitle(.init(giftBox: giftBox, boxDesign: boxDesign)))
                    return .none

                default:
                    return .none
                }

            default:
                return .none
            }
        }
        .forEach(\.path, action: /Action.path) {
            HomeNavigationPath()
        }
    }
}
