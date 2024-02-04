//
//  DeleteAccountView.swift
//  Packy
//
//  Created Mason Kim on 2/4/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct DeleteAccountView: View {
    private let store: StoreOf<DeleteAccountFeature>
    @ObservedObject private var viewStore: ViewStoreOf<DeleteAccountFeature>

    init(store: StoreOf<DeleteAccountFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        Group {
            switch viewStore.showingState {
            case .signOut:
                signOutContentView
            case .completed:
                signOutCompletedView
            }
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

private extension DeleteAccountView {
    var signOutContentView: some View {
        VStack(spacing: 0) {
            NavigationBar(title: "회원 탈퇴", leftIcon: Image(.arrowLeft), leftIconAction: {
                viewStore.send(.backButtonTapped)
            })
            .padding(.top, 8)

            VStack(spacing: 0) {
                Text("탈퇴하기 전에\n꼭 확인해주세요")
                    .packyFont(.heading1)
                    .foregroundStyle(.gray900)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 40)

                VStack(spacing: 8) {
                    infoTextView(text: "패키에서 주고 받은 선물박스, 친구와의 추억이 모두 사라져요.")
                    infoTextView(text: "회원 탈퇴 시, 즉시 탈퇴 처리가 되며 더이상 패키 서비스를 이용할 수 없어요.")
                    infoTextView(text: "탈퇴 이후 계정을 복구할 수 없어요.")
                }
                .padding(.top, 28)
            }
            .padding(.horizontal, 24)

            Spacer()

            PackyButton(title: "탈퇴하기", colorType: .black) {
                viewStore.send(.signOutButtonTapped)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
    }

    func infoTextView(text: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Circle()
                .fill(.gray800)
                .frame(width: 4, height: 4)
                .offset(y: 12)

            Text(text)
                .packyFont(.body2)
                .foregroundStyle(.gray800)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var signOutCompletedView: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("탈퇴가 완료되었어요")
                .packyFont(.heading1)
                .foregroundStyle(.gray900)
                .padding(.bottom, 16)

            Text("그동안 패키와 함께해주셔서 감사합니다.\n더 나은 모습으로 만날 수 있도록 노력하겠습니다.")
                .packyFont(.body4)
                .foregroundStyle(.gray800)
                .multilineTextAlignment(.center)

            Spacer()

            PackyButton(title: "확인", colorType: .black) {
                viewStore.send(.completedConfirmButtonTapped)
            }

            .padding(.bottom, 16)
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Preview

#Preview {
    DeleteAccountView(
        store: .init(
            initialState: .init(),
            reducer: {
                DeleteAccountFeature()
                    ._printChanges()
            }
        )
    )
}
