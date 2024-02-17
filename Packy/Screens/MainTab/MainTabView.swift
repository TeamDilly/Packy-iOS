//
//  MainTabView.swift
//  Packy
//
//  Created Mason Kim on 2/17/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct MainTabView: View {
    private let store: StoreOf<MainTabFeature>
    @ObservedObject private var viewStore: ViewStoreOf<MainTabFeature>

    init(store: StoreOf<MainTabFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        NavigationStackStore(store.scope(state: \.path, action: \.path)) {
            content
        } destination: { state in
            switch state {
            case .myBox:
                CaseLet(
                    \MainTabNavigationPath.State.myBox,
                     action: MainTabNavigationPath.Action.myBox,
                     then: MyBoxView.init
                )

            case .boxDetail:
                CaseLet(
                    \MainTabNavigationPath.State.boxDetail,
                     action: MainTabNavigationPath.Action.boxDetail,
                     then: BoxDetailView.init
                )

            case .boxOpen:
                CaseLet(
                    \MainTabNavigationPath.State.boxOpen,
                     action: MainTabNavigationPath.Action.boxOpen,
                     then: BoxOpenView.init
                )

            case .setting:
                CaseLet(
                    \MainTabNavigationPath.State.setting,
                     action: MainTabNavigationPath.Action.setting,
                     then: SettingView.init
                )

            case .manageAccount:
                CaseLet(
                    \MainTabNavigationPath.State.manageAccount,
                     action: MainTabNavigationPath.Action.manageAccount,
                     then: ManageAccountView.init
                )

            case .deleteAccount:
                CaseLet(
                    \MainTabNavigationPath.State.deleteAccount,
                     action: MainTabNavigationPath.Action.deleteAccount,
                     then: DeleteAccountView.init
                )

            case .boxAddInfo:
                CaseLet(
                    \MainTabNavigationPath.State.boxAddInfo,
                     action: MainTabNavigationPath.Action.boxAddInfo,
                     then: BoxAddInfoView.init
                )

            case .boxChoice:
                CaseLet(
                    \MainTabNavigationPath.State.boxChoice,
                     action: MainTabNavigationPath.Action.boxChoice,
                     then: BoxChoiceView.init
                )

            case .makeBoxDetail:
                CaseLet(
                    \MainTabNavigationPath.State.makeBoxDetail,
                     action: MainTabNavigationPath.Action.makeBoxDetail,
                     then: MakeBoxDetailView.init
                )

            case .addTitle:
                CaseLet(
                    \MainTabNavigationPath.State.addTitle,
                     action: MainTabNavigationPath.Action.addTitle,
                     then: BoxAddTitleAndShareView.init
                )

            case .webContent:
                CaseLet(
                    \MainTabNavigationPath.State.webContent,
                     action: MainTabNavigationPath.Action.webContent,
                     then: WebContentView.init
                )
            }
        }
    }
}

// MARK: - Inner Views

private extension MainTabView {
    var content: some View {
        VStack(spacing: 0) {
            tabView
            bottomTabBar
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden()
        .task {
            await viewStore
                .send(._onTask)
                .finish()
        }
    }

    var tabView: some View {
        TabView(selection: viewStore.$selectedTab) {
            HomeView(store: store.scope(state: \.home, action: \.home))
                .tag(MainTab.home)

            MyBoxView(store: store.scope(state: \.myBox, action: \.myBox))
                .tag(MainTab.myBox)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }

    var bottomTabBar: some View {
        VStack(spacing: 0) {
            PackyDivider()

            HStack {
                ForEach(MainTab.allCases, id: \.self) { tab in
                    HStack {
                        let isSelected = viewStore.selectedTab == tab
                        tab.image(forSelected: isSelected)
                    }
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        viewStore.send(.binding(.set(\.$selectedTab, tab)))
                    }
                }
            }
            .frame(height: 72)
        }
        .animation(.spring, value: viewStore.selectedTab)

    }
}

// MARK: - Preview

#Preview {
    MainTabView(
        store: .init(
            initialState: .init(),
            reducer: {
                MainTabFeature()
                    ._printChanges()
            }
        )
    )
}
