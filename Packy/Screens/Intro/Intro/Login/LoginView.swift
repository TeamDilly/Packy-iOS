//
//  LoginView.swift
//  Packy
//
//  Created Mason Kim on 1/7/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct LoginView: View {
    private let store: StoreOf<LoginFeature>
    @ObservedObject private var viewStore: ViewStoreOf<LoginFeature>

    init(store: StoreOf<LoginFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(.packyLogoPurple)
                .padding(.bottom, 24)
                .padding(.top, 24)
            Text("마음으로 채우는 특별한 선물박스")
                .packyFont(.body2)

            Spacer()

            VStack(spacing: 8) {
                SocialLoginButton(loginType: .kakao) {
                    viewStore.send(.kakaoLoginButtonTapped)
                }

                SocialLoginButton(loginType: .apple) {
                    viewStore.send(.appleLoginButtonTapped)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 120)
        }
    }
}

// MARK: - Preview

#Preview {
    LoginView(
        store: .init(
            initialState: .init(),
            reducer: {
                LoginFeature()
                    ._printChanges()
            }
        )
    )
}
