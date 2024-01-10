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
                Image(.mock)
                    .resizable()
                    .frame(width: 160, height: 160)
                    .mask(Circle())

                HStack(spacing: 16) {
                    ForEach(0..<4, id: \.self) { _ in
                        Image(.mock)
                            .resizable()
                            .frame(width: 60, height: 60)
                            .mask(Circle())
                            .bouncyTapGesture {
                                HapticManager.shared.fireNotification(.success)
                            }
                    }
                }
            }

            Spacer()

            PackyNavigationLink(title: "저장", pathState: SignUpNavigationPath.State.termsAgreement())
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
        }
        // .animation(.spring, value: viewStore.nickname) // TODO: 프로필 변경에 따라 애니메이션 부옇!
        .navigationBarBackButtonHidden(true)
        .task {
            await viewStore
                .send(._onAppear)
                .finish()
        }
    }
}

// MARK: - Preview

#Preview {
    SignUpProfileView(
        store: .init(
            initialState: .init(),
            reducer: {
                SignUpProfileFeature()
                    ._printChanges()
            }
        )
    )
}
