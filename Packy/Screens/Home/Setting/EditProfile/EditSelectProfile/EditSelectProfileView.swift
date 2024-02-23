//
//  EditSelectProfileView.swift
//  Packy
//
//  Created Mason Kim on 2/19/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct EditSelectProfileView: View {
    private let store: StoreOf<EditSelectProfileFeature>

    init(store: StoreOf<EditSelectProfileFeature>) {
        self.store = store
    }

    var body: some View {
        VStack(spacing: 0) {
            NavigationBar.onlyBackButton {
                store.send(.backButtonTapped)
            }
            .padding(.top, 8)

            NetworkImage(
                url: store.selectedProfile?.imageUrl ?? store.initialImageUrl
            )
            .frame(width: 160, height: 160)
            .padding(.top, 60)

            HStack(spacing: 16) {
                ForEach(store.profileImages, id: \.id) { profileImage in
                    NetworkImage(url: profileImage.imageUrl)
                        .frame(width: 60, height: 60)
                        .bouncyTapGesture {
                            store.send(.selectProfile(profileImage))
                        }
                }
            }
            .padding(.top, 40)

            Spacer()

            PackyButton(title: "확인", sizeType: .large, colorType: .black) {
                store.send(.confirmButtonTapped)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .navigationBarBackButtonHidden(true)
        .task {
            await store
                .send(._onTask)
                .finish()
        }
    }
}

// MARK: - Preview

#Preview {
    EditSelectProfileView(
        store: .init(
            initialState: .init(initialImageUrl: Constants.mockImageUrl),
            reducer: {
                EditSelectProfileFeature()
                    ._printChanges()
            }
        )
    )
}
