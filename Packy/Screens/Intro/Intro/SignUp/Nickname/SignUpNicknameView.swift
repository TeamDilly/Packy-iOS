//
//  SignUpNicknameView.swift
//  Packy
//
//  Created Mason Kim on 1/9/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct SignUpNicknameView: View {
    @Bindable private var store: StoreOf<SignUpNicknameFeature>
    @FocusState private var isFocused: Bool

    init(store: StoreOf<SignUpNicknameFeature>) {
        self.store = store
    }

    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            content
        } destination: { store in
            switch store.state {
            case .profile:
                if let store = store.scope(state: \.profile, action: \.profile) {
                    SignUpProfileView(store: store)
                }

            case .termsAgreement:
                if let store = store.scope(state: \.termsAgreement, action: \.termsAgreement) {
                    TermsAgreementView(store: store)
                }
            }
        }
    }
}

// MARK: - Inner Views

private extension SignUpNicknameView {
    var content: some View {
        VStack(spacing: 0) {
            Text("패키에서 사용할\n닉네임을 입력해주세요")
                .packyFont(.heading1)
                .foregroundStyle(.gray900)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 64)
                .padding(.bottom, 8)

            Text("친구들이 나를 잘 알아볼 수 있는 닉네임으로 설정해주세요")
                .packyFont(.body4)
                .foregroundStyle(.gray600)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 40)

            PackyTextField(
                text: $store.nickname,
                placeholder: "6자 이내로 입력해주세요"
            )
            .focused($isFocused)
            .limitTextLength(text: $store.nickname, length: 6)

            Spacer()

            PackyNavigationLink(
                title: "저장",
                pathState: SignUpNavigationPath.State.profile(
                    .init(
                        socialLoginInfo: store.socialLoginInfo,
                        nickName: store.nickname
                    )
                )
            )
            .disabled(store.nickname.count < 2)
            .padding(.bottom, 16)
        }
        .animation(.spring, value: store.nickname)
        .padding(.horizontal, 24)
        .makeTapToHideKeyboard()
        .task {
            await store
                .send(._onAppear)
                .finish()
            isFocused = true
        }
    }
}


// MARK: - Preview

#Preview {
    SignUpNicknameView(
        store: .init(
            initialState: .init(socialLoginInfo: SocialLoginInfo(id: "", authorization: "", name: "", email: nil, provider: .kakao)),
            reducer: {
                SignUpNicknameFeature()
                    ._printChanges()
            }
        )
    )
}
