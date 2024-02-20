//
//  SettingView.swift
//  Packy
//
//  Created Mason Kim on 2/4/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct SettingView: View {
    private let store: StoreOf<SettingFeature>
    @ObservedObject private var viewStore: ViewStoreOf<SettingFeature>

    init(store: StoreOf<SettingFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        VStack(spacing: 0) {
            NavigationBar.onlyBackButton {
                viewStore.send(.backButtonTapped)
            }
            .padding(.top, 8)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    profileView

                    let destination = MainTabNavigationPath.State.manageAccount(
                        .init(socialLoginProvider: viewStore.profile?.provider)
                    )
                    NavigationLink(state: destination) {
                        SettingListCell(title: "계정 관리")
                    }

                    PackyDivider()

                    // 서버에서 받아온 설정 링크들
                    ForEach(SettingMenuType.allCases, id: \.self) { menuType in
                        let urlString = viewStore.settingMenus.first { $0.type == menuType }?.url ?? ""

                        let destinationState = MainTabNavigationPath.State.webContent(.init(urlString: urlString, navigationTitle: menuType.title))
                        NavigationLink(state: destinationState) {
                            SettingListCell(title: menuType.title)
                        }

                        if case .sendComment = menuType {
                            PackyDivider()
                        }
                    }

                    versionView

                    PackyDivider()

                    Button {
                        viewStore.send(.logoutButtonTapped)
                    } label: {
                        SettingListCell(title: "로그아웃", showRightIcon: false)
                    }
                }
                .padding(24)

            }


            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .task {
            await viewStore
                .send(._onTask)
                .finish()
        }
    }
}

// MARK: - Inner Views

private extension SettingView {
    var profileView: some View {
        HStack {
            HStack(spacing: 16) {
                NetworkImage(url: viewStore.profile?.imageUrl ?? "")
                    .frame(width: 60, height: 60)

                Text(viewStore.profile?.nickname ?? "")
                    .packyFont(.heading2)
                    .foregroundStyle(.gray900)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if viewStore.profile != nil {
                Button("프로필 수정") {
                    viewStore.send(.editProfileButtonTapped)
                }
                .buttonStyle(.box(color: .tertiary, size: .roundSmall))
            }
        }
        .navigationDestination(
            store: store.scope(state: \.$editProfile, action: \.editProfile)
        ) { store in
            EditProfileView(store: store)
        }
    }

    var versionView: some View {
        HStack(spacing: 8) {
            Text("버전")
                .packyFont(.body2)
                .foregroundStyle(.gray900)

            Text(Constants.appVersion)
                .packyFont(.body4)
                .foregroundStyle(.gray600)
        }
    }
}

// MARK: - Preview

#Preview {
    SettingView(
        store: .init(
            initialState: .init(profile: .mock),
            reducer: {
                SettingFeature()
                    ._printChanges()
            }
        )
    )
}
