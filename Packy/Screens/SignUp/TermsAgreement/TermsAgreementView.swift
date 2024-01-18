//
//  TermsAgreementView.swift
//  Packy
//
//  Created Mason Kim on 1/7/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct TermsAgreementView: View {
    private let store: StoreOf<TermsAgreementFeature>
    @ObservedObject private var viewStore: ViewStoreOf<TermsAgreementFeature>

    init(store: StoreOf<TermsAgreementFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        VStack {
            NavigationBar.onlyBackButton {
                viewStore.send(.backButtonTapped)
            }
            .padding(.bottom, 8)

            Text("서비스 사용을 위한\n약관에 동의해주세요")
                .packyFont(.heading1)
                .foregroundStyle(.gray900)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 40)
                .padding(.horizontal, 24)

            VStack(alignment: .leading, spacing: 16) {
                Button {
                    viewStore.send(.agreeAllTermsButtonTapped)
                    HapticManager.shared.fireFeedback(.medium)
                } label: {
                    allAgreedView(isChecked: viewStore.isAllTermsAgreed)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                }

                Group {
                    ForEach(Terms.allCases, id: \.self) { terms in
                        Button {
                            viewStore.send(.agreeTermsButtonTapped(terms))
                            HapticManager.shared.fireFeedback(.light)
                        } label: {
                            Checkbox(isChecked: viewStore.termsStates[terms] ?? false, label: terms.title)
                                .containerShape(Rectangle())
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding(.leading, 12)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)

            Spacer()

            PackyButton(title: "확인") {
                viewStore.send(.confirmButtonTapped)
            }
            .disabled(!viewStore.isAllRequiredTermsAgreed)
            .animation(.spring, value: viewStore.isAllRequiredTermsAgreed)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .bottomSheet(
            isPresented: viewStore.$isAllowNotificationBottomSheetPresented,
            detents: [.height(591)]
        ) {
            bottomSheetContent
        }
        .navigationBarBackButtonHidden(true)
        .task {
            await viewStore
                .send(._onAppear)
                .finish()
        }
    }
}

// MARK: - Inner Views

private extension TermsAgreementView {
    func allAgreedView(isChecked: Bool) -> some View {
        HStack(spacing: 12) {
            Image(.check)
                .renderingMode(.template)
                .foregroundStyle(isChecked ? .purple500 : .gray400)
                .animation(.spring, value: isChecked)
                .padding(.leading, 12)

            Text("전체 동의하기")
                .packyFont(.body2)
                .foregroundStyle(.gray800)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.gray100)
                .frame(height: 50)
        )
    }

    var bottomSheetContent: some View {
        VStack(spacing: 0) {
            Text("선물박스가 도착하면\n알려드릴까요?")
                .frame(maxWidth: .infinity, alignment: .leading)
                .packyFont(.heading1)
                .foregroundStyle(.gray900)
                .padding(.vertical, 8)

            Text("알림을 허용해주시면 선물이 도착하거나\n친구가 선물을 받을 때 알림을 보내드려요.")
                .frame(maxWidth: .infinity, alignment: .leading)
                .packyFont(.body4)
                .foregroundStyle(.gray600)

            Image(.mock)
                .resizable()
                .scaledToFill()
                .frame(width: 300, height: 240)
                .clipped() // 이미지 사이즈 넘치면 자름
                .padding(.vertical, 40)

            Spacer()

            PackyButton(title: "허용하기") {
                viewStore.send(.allowNotificationButtonTapped)
            }
            .padding(.bottom, 16)
        }
    }
}

// MARK: - Preview

#Preview {
    TermsAgreementView(
        store: .init(
            initialState: .init(socialLoginInfo: .mock, nickName: "mason", selectedProfileIndex: 0),
            reducer: {
                TermsAgreementFeature()
                    ._printChanges()
            }
        )
    )
}
