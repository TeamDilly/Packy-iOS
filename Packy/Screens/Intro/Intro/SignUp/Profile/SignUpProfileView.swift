//
//  SignUpProfileView.swift
//  Packy
//
//  Created Mason Kim on 1/9/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct SignUpProfileView: View {
    private let store: StoreOf<SignUpProfileFeature>
    @ObservedObject private var viewStore: ViewStoreOf<SignUpProfileFeature>

    init(store: StoreOf<SignUpProfileFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        VStack(spacing: 0) {
            NavigationBar.onlyBackButton {
                viewStore.send(.backButtonTapped)
            }
            .padding(.bottom, 8)

            Text("프로필을 선택해주세요")
                .packyFont(.heading1)
                .foregroundStyle(.gray900)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 80)
                .padding(.horizontal, 24)

            VStack(spacing: 40) {
                if let selectedImageUrl = viewStore.selectedProfileImage?.imageUrl {
                    NetworkImage(url: selectedImageUrl)
                        .frame(width: 160, height: 160)
                }

                HStack(spacing: 16) {
                    ForEach(viewStore.profileImages, id: \.id) { profileImage in
                        Button {
                            viewStore.send(.selectProfile(profileImage))
                            HapticManager.shared.fireFeedback(.medium)
                        } label: {
                            NetworkImage(url: profileImage.imageUrl)
                                .frame(width: 60, height: 60)
                        }
                        .buttonStyle(.bouncy)
                    }
                }
            }
            .animation(.spring, value: viewStore.selectedProfileImage)

            Spacer()

            PackyNavigationLink(
                title: "저장",
                pathState: SignUpNavigationPath.State.termsAgreement(
                    .init(
                        socialLoginInfo: viewStore.socialLoginInfo,
                        nickName: viewStore.nickName,
                        selectedProfileId: viewStore.selectedProfileImage?.id ?? 0
                    )
                )
            )
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .navigationBarBackButtonHidden(true)
        .task {
            await viewStore
                .send(._onTask)
                .finish()
        }
    }
}

// MARK: - Preview

#Preview {
    SignUpProfileView(
        store: .init(
            initialState: .init(socialLoginInfo: .mock, nickName: "mason"),
            reducer: {
                SignUpProfileFeature()
                    ._printChanges()
            }
        )
    )
}
