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

                    NavigationLink(state: HomeNavigationPath.State.manageAccount()) {
                        SettingListCell(title: "계정 관리")
                    }

                    PackyDivider()

                    SettingListCell(title: "패키 공식 SNS")
                    SettingListCell(title: "1:1 문의하기")
                    SettingListCell(title: "패키에게 의견 보내기")

                    PackyDivider()

                    SettingListCell(title: "개인정보처리방침")
                    SettingListCell(title: "이용약관")
                    versionView

                    PackyDivider()

                    SettingListCell(title: "로그아웃", showRightIcon: false)
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
        HStack(spacing: 16) {
            NetworkImage(url: Constants.mockImageUrl)
                .frame(width: 60, height: 60)

            Text("메이슨")
                .packyFont(.heading2)
                .foregroundStyle(.gray900)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
            initialState: .init(),
            reducer: {
                SettingFeature()
                    ._printChanges()
            }
        )
    )
}
