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
    @ObservedObject private var viewStore: ViewStoreOf<EditSelectProfileFeature>

    init(store: StoreOf<EditSelectProfileFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        VStack(spacing: 0) {
            NavigationBar.onlyBackButton {
                viewStore.send(.backButtonTapped)
            }
            .padding(.top, 8)

            NetworkImage(url: viewStore.selectedImageUrl)
                .frame(width: 160, height: 160)
                .padding(.top, 60)

            HStack(spacing: 16) {
                ForEach(viewStore.profileImages, id: \.id) { profileImage in
                    NetworkImage(url: profileImage.imageUrl)
                        .frame(width: 60, height: 60)
                        .bouncyTapGesture {
                            viewStore.send(.selectProfile(profileImage))
                        }
                }
            }
            .padding(.top, 40)

            Spacer()

            PackyButton(title: "확인", sizeType: .large, colorType: .black) {
                viewStore.send(.confirmButtonTapped)
            }
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
    EditSelectProfileView(
        store: .init(
            initialState: .init(selectedImageUrl: Constants.mockImageUrl),
            reducer: {
                EditSelectProfileFeature()
                    ._printChanges()
            }
        )
    )
}
