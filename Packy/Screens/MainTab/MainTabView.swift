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
    @Bindable private var store: StoreOf<MainTabFeature>

    init(store: StoreOf<MainTabFeature>) {
        self.store = store
    }

    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            content
        } destination: { store in
            switch store.state {
            case .boxDetail:
                if let store = store.scope(state: \.boxDetail, action: \.boxDetail) {
                    BoxDetailView(store: store)
                }

            case .boxOpen:
                if let store = store.scope(state: \.boxOpen, action: \.boxOpen) {
                    BoxOpenView(store: store)
                }
            
            case .setting:
                if let store = store.scope(state: \.setting, action: \.setting) {
                    SettingView(store: store)
                }

            case .manageAccount:
                if let store = store.scope(state: \.manageAccount, action: \.manageAccount) {
                    ManageAccountView(store: store)
                }

            case .deleteAccount:
                if let store = store.scope(state: \.deleteAccount, action: \.deleteAccount) {
                    DeleteAccountView(store: store)
                }

            case .boxAddInfo:
                if let store = store.scope(state: \.boxAddInfo, action: \.boxAddInfo) {
                    BoxAddInfoView(store: store)
                }

            case .boxChoice:
                if let store = store.scope(state: \.boxChoice, action: \.boxChoice) {
                    BoxChoiceView(store: store)
                }

            case .makeBoxDetail:
                if let store = store.scope(state: \.makeBoxDetail, action: \.makeBoxDetail) {
                    MakeBoxDetailView(store: store)
                }

            case .addTitle:
                if let store = store.scope(state: \.addTitle, action: \.addTitle) {
                    BoxAddTitleAndShareView(store: store)
                }

            case .boxShare:
                if let store = store.scope(state: \.boxShare, action: \.boxShare) {
                    BoxShareView(store: store)
                }

            case .webContent:
                if let store = store.scope(state: \.webContent, action: \.webContent) {
                    WebContentView(store: store)
                }
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
                get: { store.popupBox.popupBox != nil },
                set: {
                    guard $0 == false else { return }
                    store.send(.popupBox(._hideBottomSheet))
                }
            ),
            detents: [.height(525)]
        ) {
            PopupBoxBottomSheet(store: store.scope(state: \.popupBox, action: \.popupBox))
        }
        .navigationBarBackButtonHidden()
        .didLoad {
            await store
                .send(._onTask)
                .finish()
        }
    }

    var tabView: some View {
        TabView(selection: $store.selectedTab) {
            // 탭뷰 컨텐츠간의 좌우 Swipe를 막기위해 이런 형태로 작성
            switch store.selectedTab {
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
        .background(store.selectedTab.backgroundColor)
        .toolbar(.hidden, for: .tabBar)
        .tabViewStyle(.page(indexDisplayMode: .never))
    }

    var bottomTabBar: some View {
        VStack(spacing: 0) {
            PackyDivider()

            HStack {
                ForEach(MainTab.allCases, id: \.self) { tab in
                    HStack {
                        let isSelected = store.selectedTab == tab
                        tab.image(forSelected: isSelected)
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        store.send(.binding(.set(\.selectedTab, tab)))
                    }
                }
            }
            .frame(height: 72)
        }
        .animation(.easeInOut, value: store.selectedTab)

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
