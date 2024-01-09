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
    private let store: StoreOf<SignUpNicknameFeature>
    @ObservedObject private var viewStore: ViewStoreOf<SignUpNicknameFeature>

    init(store: StoreOf<SignUpNicknameFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        NavigationStackStore(store.scope(state: \.path, action: \.path)) {
            content
        } destination: { state in
            switch state {
            case .profile:
                CaseLet(
                    \SignUpNavigationPath.State.profile,
                     action: SignUpNavigationPath.Action.profile,
                     then: SignUpProfileView.init
                )

            case .termsAgreement:
                CaseLet(
                    \SignUpNavigationPath.State.termsAgreement,
                     action: SignUpNavigationPath.Action.termsAgreement,
                     then: TermsAgreementView.init
                )
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
                .padding(.bottom, 16)

            Text("친구들이 나를 잘 알아볼 수 있는 닉네임으로 설정해주세요")
                .packyFont(.body4)
                .foregroundStyle(.gray600)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 40)

            PackyTextField(
                text: viewStore.$nickname,
                placeholder: "6자 이내로 입력해주세요"
            )
            .limitTextLength(text: viewStore.$nickname, length: 6)

            Spacer()

            PackyNavigationLink(title: "저장", pathState: SignUpNavigationPath.State.profile())
                .disabled(viewStore.nickname.isEmpty)
                .padding(.bottom, 16)
        }
        .animation(.spring, value: viewStore.nickname)
        .padding(.horizontal, 24)
        .task {
            await viewStore
                .send(._onAppear)
                .finish()
        }
    }
}


// MARK: - Preview

#Preview {
    SignUpNicknameView(
        store: .init(
            initialState: .init(),
            reducer: {
                SignUpNicknameFeature()
                    ._printChanges()
            }
        )
    )
}
