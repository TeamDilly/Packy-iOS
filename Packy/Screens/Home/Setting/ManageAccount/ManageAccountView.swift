//
//  ManageAccountView.swift
//  Packy
//
//  Created Mason Kim on 2/4/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct ManageAccountView: View {
    private let store: StoreOf<ManageAccountFeature>
    @ObservedObject private var viewStore: ViewStoreOf<ManageAccountFeature>

    init(store: StoreOf<ManageAccountFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        VStack(spacing: 0) {
            NavigationBar(title: "계정 관리", leftIcon: Image(.arrowLeft), leftIconAction: {
                viewStore.send(.backButtonTapped)
            })
            .padding(.top, 8)

            VStack(spacing: 24) {
                connectedSocialAccountView

                NavigationLink(state: HomeNavigationPath.State.deleteAccount()) {
                    SettingListCell(title: "회원탈퇴")
                }
            }
            .padding(24)

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

private extension ManageAccountView {
    var connectedSocialAccountView: some View {
        HStack(spacing: 4) {
            Text("연결된 계정")
                .packyFont(.body2)
                .foregroundStyle(.gray900)

            Spacer()

            let provider: SocialLoginProvider = .apple
            Text(provider.description)
                .packyFont(.body4)
                .foregroundStyle(.gray600)

            Circle()
                .fill(provider.backgroundColor)
                .frame(width: 24, height: 24)
                .overlay {
                    Image(provider.imageResource)
                        .resizable()
                        .frame(width: 12, height: 12)
                }
        }
    }
}

// MARK: - Preview

#Preview {
    ManageAccountView(
        store: .init(
            initialState: .init(),
            reducer: {
                ManageAccountFeature()
                    ._printChanges()
            }
        )
    )
}
