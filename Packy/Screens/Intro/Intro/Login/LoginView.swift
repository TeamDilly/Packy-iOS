//
//  LoginView.swift
//  Packy
//
//  Created Mason Kim on 1/7/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

@ViewAction(for: LoginFeature.self)
struct LoginView: View {
    let store: StoreOf<LoginFeature>

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
                    send(.kakaoLoginButtonTapped)
                }

                SocialLoginButton(loginType: .apple) {
                    send(.appleLoginButtonTapped)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 120)
        }
        .analyticsLog(.login)
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
