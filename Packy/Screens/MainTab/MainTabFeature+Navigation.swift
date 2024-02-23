//
//  MainTabFeature+Navigation.swift
//  Packy
//
//  Created Mason Kim on 2/17/24.
//

import ComposableArchitecture

// MARK: - Navigation Path

@Reducer
struct MainTabNavigationPath {
    @ObservableState
    enum State: Equatable {
        case boxDetail(BoxDetailFeature.State)
        case boxOpen(BoxOpenFeature.State)

        case setting(SettingFeature.State)
        // TODO: Edit ~ Delete 부분 PresentationState 로 변경 _ Path에 반영되는지 확인 필요...
        case manageAccount(ManageAccountFeature.State)
        case deleteAccount(DeleteAccountFeature.State = .init())

        case boxAddInfo(BoxAddInfoFeature.State = .init())
        case boxChoice(BoxChoiceFeature.State)
        case makeBoxDetail(MakeBoxDetailFeature.State)
        case addTitle(BoxAddTitleAndShareFeature.State)
        case boxShare(BoxShareFeature.State)

        case webContent(WebContentFeature.State)
    }

    enum Action {
        case boxDetail(BoxDetailFeature.Action)
        case boxOpen(BoxOpenFeature.Action)

        case setting(SettingFeature.Action)
        case manageAccount(ManageAccountFeature.Action)
        case deleteAccount(DeleteAccountFeature.Action)

        case boxAddInfo(BoxAddInfoFeature.Action)
        case boxChoice(BoxChoiceFeature.Action)
        case makeBoxDetail(MakeBoxDetailFeature.Action)
        case addTitle(BoxAddTitleAndShareFeature.Action)
        case boxShare(BoxShareFeature.Action)

        case webContent(WebContentFeature.Action)
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.boxDetail, action: \.boxDetail) { BoxDetailFeature() }
        Scope(state: \.boxOpen, action: \.boxOpen) { BoxOpenFeature() }

        Scope(state: \.setting, action: \.setting) { SettingFeature() }
        Scope(state: \.manageAccount, action: \.manageAccount) { ManageAccountFeature() }
        Scope(state: \.deleteAccount, action: \.deleteAccount) { DeleteAccountFeature() }

        Scope(state: \.boxAddInfo, action: \.boxAddInfo) { BoxAddInfoFeature() }
        Scope(state: \.boxChoice, action: \.boxChoice) { BoxChoiceFeature() }
        Scope(state: \.makeBoxDetail, action: \.makeBoxDetail) { MakeBoxDetailFeature() }
        Scope(state: \.addTitle, action: \.addTitle) { BoxAddTitleAndShareFeature() }
        Scope(state: \.boxShare, action: \.boxShare) { BoxShareFeature() }

        Scope(state: \.webContent, action: \.webContent) { WebContentFeature() }
    }
}

// MARK: - Navigation Reducer

extension MainTabFeature {
    var navigationReducer: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {

            case let .myBox(.delegate(.moveToBoxDetail(boxId, giftBox, isToSend))),
                 let .home(.delegate(.moveToBoxDetail(boxId, giftBox, isToSend))):
                state.path.append(.boxDetail(.init(boxId: boxId, giftBox: giftBox, isToSend: isToSend)))
                return .none

            case let .path(action):
                switch action {
                    /// 회원탈퇴, 로그아웃 완료, 박스 공유창 닫기 시 Stack 전부 비우기
                case .element(id: _, action: .deleteAccount(.delegate(.completedSignOut))),
                        .element(id: _, action: .setting(.delegate(.completeSignOut))),
                        .element(id: _, action: .boxChoice(.delegate(.closeMakeBox))),
                        .element(id: _, action: .boxOpen(.delegate(.moveToHome))),
                        .element(id: _, action: .addTitle(.delegate(.moveToHome))),
                        .element(id: _, action: .boxShare(.delegate(.moveToHome))):
                    state.path.removeAll()
                    return .none

                case let .element(id: _, action: .boxChoice(.delegate(.moveToMakeBoxDetail(data)))):
                    state.path.append(.makeBoxDetail(.init(senderInfo: data.senderInfo, boxDesigns: data.boxDesigns, selectedBox: data.selectedBox)))
                    return .none

                case let .element(id: _, action: .makeBoxDetail(.delegate(.moveToAddTitle(giftBoxData, boxDesign)))):
                    state.path.append(.addTitle(.init(giftBoxData: giftBoxData, boxDesign: boxDesign)))
                    return .none

                case let .element(id: _, action: .boxOpen(.delegate(.moveToBoxDetail(boxId, giftBox)))):
                    state.path.append(.boxDetail(.init(boxId: boxId, giftBox: giftBox, isToSend: false)))
                    return .none

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

                case let .element(id: _, action: .boxDetail(.delegate(.moveToBoxShare(data)))):
                    state.path.append(.boxShare(.init(data: data, showCompleteAnimation: false)))
                    return .none

                default:
                    return .none
                }

            default:
                return .none
            }
        }
        .forEach(\.path, action: /Action.path) {
            MainTabNavigationPath()
        }
    }
}
