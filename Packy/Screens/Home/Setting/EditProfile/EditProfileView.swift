//
//  EditProfileView.swift
//  Packy
//
//  Created Mason Kim on 2/19/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct EditProfileView: View {
    @Bindable private var store: StoreOf<EditProfileFeature>

    init(store: StoreOf<EditProfileFeature>) {
        self.store = store
    }
    
    var body: some View {
        VStack(spacing: 40) {
            NavigationBar(title: "프로필 수정", leftIcon: Image(.arrowLeft), leftIconAction: {
                store.send(.backButtonTapped)
            })
            .padding(.top, 8)
            
            profileImageView
                .bouncyTapGesture {
                    store.send(.profileButtonTapped)
                }
            
            nicknameTextField
                .padding(.horizontal, 24)
            
            Spacer()
            
            PackyButton(title: "저장", sizeType: .large, colorType: .black) {
                store.send(.saveButtonTapped)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .makeTapToHideKeyboard()
        .navigationDestination(
            item: $store.scope(state: \.editSelectProfile, action: \.editSelectProfile)
        ) { store in
            EditSelectProfileView(store: store)
        }
        .navigationBarBackButtonHidden(true)
        .task {
            await store
                .send(._onTask)
                .finish()
        }
    }
}

// MARK: - Inner Views

private extension EditProfileView {
    var profileImageView: some View {
        NetworkImage(
            url: store.selectedProfile?.imageUrl ?? store.fetchedProfile.imageUrl
        )
        .frame(width: 80, height: 80)
        .overlay(alignment: .bottomTrailing) {
            Circle()
                .stroke(.white, lineWidth: 4)
                .fill(.gray100)
                .frame(width: 24, height: 24)
                .overlay {
                    Image(.pencil)
                        .resizable()
                        .frame(width: 16, height: 16)
                }
        }
    }
    
    var nicknameTextField: some View {
        VStack(spacing: 4) {
            Text("닉네임")
                .packyFont(.body4)
                .foregroundStyle(.gray800)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            PackyTextField(
                text: $store.nickname,
                placeholder: "6자 이내로 입력해주세요"
            )
            .limitTextLength(text: $store.nickname, length: 6)
        }
    }
}

// MARK: - Preview

#Preview {
    EditProfileView(
        store: .init(
            initialState: .init(fetchedProfile: .mock),
            reducer: {
                EditProfileFeature()
                    ._printChanges()
            }
        )
    )
}
