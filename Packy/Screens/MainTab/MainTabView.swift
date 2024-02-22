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
    @State var presentBottomSheet: Bool = false

    init(store: StoreOf<MainTabFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        NavigationStackStore(store.scope(state: \.path, action: \.path)) {
            content
        } destination: { state in
            switch state {
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

            case .boxShare:
                CaseLet(
                    \MainTabNavigationPath.State.boxShare,
                     action: MainTabNavigationPath.Action.boxShare,
                     then: BoxShareView.init
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
        .bottomSheet(
            isPresented: .init(
                get: { viewStore.popupBox.popupBox != nil },
                set: {
                    guard $0 == false else { return }
                    viewStore.send(.popupBox(._hideBottomSheet))
                }
            ),
            detents: [.height(525)]
        ) {
            PopupBoxBottomSheet(store: store.scope(state: \.popupBox, action: \.popupBox))
        }
        .task {
            try? await Task.sleep(for: .seconds(1))
            presentBottomSheet = true
        }
        .navigationBarBackButtonHidden()
        .didLoad {
            await viewStore
                .send(._onTask)
                .finish()
        }
    }

    var tabView: some View {
        TabView(selection: viewStore.$selectedTab) {
            // 탭뷰 컨텐츠간의 좌우 Swipe를 막기위해 이런 형태로 작성
            switch viewStore.selectedTab {
            case .home:
                HomeView(store: store.scope(state: \.home, action: \.home))
                    .tag(MainTab.home)

            case .myBox:
                MyBoxView(store: store.scope(state: \.myBox, action: \.myBox))
                    .tag(MainTab.myBox)

            case .archive:
                ArchiveView(store: store.scope(state: \.archive, action: \.archive))
                    .tag(MainTab.archive)
            }
        }
        .scrollIndicators(.hidden)
        .background(viewStore.selectedTab.backgroundColor)
        .toolbar(.hidden, for: .tabBar)
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
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewStore.send(.binding(.set(\.$selectedTab, tab)))
                    }
                }
            }
            .frame(height: 72)
        }
        .animation(.easeInOut, value: viewStore.selectedTab)

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
