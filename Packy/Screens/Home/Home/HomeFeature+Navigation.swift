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
        case boxOpen(BoxOpenFeature.State)

        case setting(SettingFeature.State)
        case manageAccount(ManageAccountFeature.State)
        case deleteAccount(DeleteAccountFeature.State = .init())

        case makeBox(MakeBoxFeature.State = .init())
        case boxChoice(BoxChoiceFeature.State)
        case startGuide(BoxStartGuideFeature.State)
        case addTitle(BoxAddTitleAndShareFeature.State)

        case webContent(WebContentFeature.State)
    }

    enum Action {
        case myBox(MyBoxFeature.Action)
        case boxDetail(BoxDetailFeature.Action)
        case boxOpen(BoxOpenFeature.Action)

        case setting(SettingFeature.Action)
        case manageAccount(ManageAccountFeature.Action)
        case deleteAccount(DeleteAccountFeature.Action)

        case makeBox(MakeBoxFeature.Action)
        case boxChoice(BoxChoiceFeature.Action)
        case startGuide(BoxStartGuideFeature.Action)
        case addTitle(BoxAddTitleAndShareFeature.Action)

        case webContent(WebContentFeature.Action)
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.myBox, action: \.myBox) { MyBoxFeature() }
        Scope(state: \.boxDetail, action: \.boxDetail) { BoxDetailFeature() }
        Scope(state: \.boxOpen, action: \.boxOpen) { BoxOpenFeature() }

        Scope(state: \.setting, action: \.setting) { SettingFeature() }
        Scope(state: \.manageAccount, action: \.manageAccount) { ManageAccountFeature() }
        Scope(state: \.deleteAccount, action: \.deleteAccount) { DeleteAccountFeature() }

        Scope(state: \.makeBox, action: \.makeBox) { MakeBoxFeature() }
        Scope(state: \.boxChoice, action: \.boxChoice) { BoxChoiceFeature() }
        Scope(state: \.startGuide, action: \.startGuide) { BoxStartGuideFeature() }
        Scope(state: \.addTitle, action: \.addTitle) { BoxAddTitleAndShareFeature() }

        Scope(state: \.webContent, action: \.webContent) { WebContentFeature() }
    }
}

// MARK: - Navigation Reducer

extension HomeFeature {
    var navigationReducer: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .path(action):
                switch action {
                /// 회원탈퇴, 로그아웃 완료, 박스 공유창 닫기 시 Stack 전부 비우기
                case .element(id: _, action: .deleteAccount(.delegate(.completedSignOut))),
                     .element(id: _, action: .setting(.delegate(.completeSignOut))),
                     .element(id: _, action: .addTitle(.delegate(.moveToHome))),
                     .element(id: _, action: .boxChoice(.delegate(.closeMakeBox))),
                     .element(id: _, action: .boxOpen(.delegate(.moveToHome))):
                    state.path.removeAll()
                    return .none

                case let .element(id: _, action: .boxChoice(.delegate(.moveToBoxStartGuide(data)))):
                    state.path.append(.startGuide(.init(senderInfo: data.senderInfo, boxDesigns: data.boxDesigns, selectedBox: data.selectedBox)))
                    return .none

                case let .element(id: _, action: .startGuide(.delegate(.moveToAddTitle(giftBox, boxDesign)))):
                    state.path.append(.addTitle(.init(giftBox: giftBox, boxDesign: boxDesign)))
                    return .none

                case let .element(id: _, action: .boxOpen(.delegate(.moveToBoxDetail(giftBox)))):
                    state.path.append(.boxDetail(.init(giftBox: giftBox)))
                    return .none

                case let .element(id: _, action: .myBox(.delegate(.tappedGifBox(boxId)))):
                    return .send(.tappedGiftBox(boxId: boxId))

                /// Box Detail 에서 닫기 시,
                case .element(id: _, action: .boxDetail(.delegate(.closeBoxOpen))):
                    // BoxOpen 에서 열린 BoxDetail 이면 Home 까지 다 닫아줌
                    let hasBoxOpen = state.path.contains { state in
                        guard case .boxOpen = state else { return false }
                        return true
                    }
                    if hasBoxOpen {
                        state.path.removeAll()
                    } else {
                        // 아니면 BoxDetail 만 닫음 (ex. List에서 진입 시)
                        state.path.removeLast()
                    }
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
