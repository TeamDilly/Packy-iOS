//
//  MainTabFeature.swift
//  Packy
//
//  Created Mason Kim on 2/17/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct MainTabFeature: Reducer {

    @ObservableState
    struct State: Equatable {
        var textInput: String = ""
        var selectedTab: MainTab = .home

        var path: StackState<MainTabNavigationPath.State> = .init()
        
        var home: HomeFeature.State = .init()
        var myBox: MyBoxFeature.State = .init()
        var archive: ArchiveFeature.State = .init()

        var popupBox: PopupGiftBoxFeature.State = .init()
    }

    enum Action: ViewAction {
        case view(View)

        // MARK: Child Action
        case path(StackAction<MainTabNavigationPath.State, MainTabNavigationPath.Action>)
        case home(HomeFeature.Action)
        case myBox(MyBoxFeature.Action)
        case archive(ArchiveFeature.Action)
        case popupBox(PopupGiftBoxFeature.Action)

        enum View: BindableAction {
            case binding(BindingAction<State>)
            case onTask
        }
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.home, action: \.home) { HomeFeature() }
        Scope(state: \.myBox, action: \.myBox) { MyBoxFeature() }
        Scope(state: \.archive, action: \.archive) { ArchiveFeature() }

        Scope(state: \.popupBox, action: \.popupBox) { PopupGiftBoxFeature() }

        BindingReducer(action: \.view)
        navigationReducer

        Reduce<State, Action> { state, action in
            switch action {

            case let .view(action):
                switch action {
                case .onTask:
                    return .send(.popupBox(._fetchPopupGiftBox))

                case .binding:
                    return .none
                }

            // MARK: Child Action
            case .home(.delegate(.moveToMyBox)):
                state.selectedTab = .myBox
                return .none

            case let .popupBox(.delegate(.moveToOpenBox(boxId, giftBox))):
                state.path.append(.boxOpen(.init(boxId: boxId, showingState: .openMotion, giftBox: giftBox)))
                let boxOpenId = state.path.ids.last ?? 0
                return .send(.path(.element(id: boxOpenId, action: .boxOpen(._showAnimationAndGoToDetail(boxId: boxId, giftBox)))))

            default:
                return .none
            }
        }
    }
}
