//
//  WebContentView.swift
//  Packy
//
//  Created Mason Kim on 2/5/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct WebContentView: View {
    private let store: StoreOf<WebContentFeature>

    init(store: StoreOf<WebContentFeature>) {
        self.store = store
    }

    var body: some View {
        VStack {
            NavigationBar(
                title: store.navigationTitle,
                leftIcon: Image(.arrowLeft), 
                leftIconAction: {
                    store.send(.backButtonTapped)
                }
            )

            WebView(urlString: store.urlString)
        }
        .navigationBarBackButtonHidden()
        .task {
            await store
                .send(._onTask)
                .finish()
        }
    }
}

// MARK: - Preview

#Preview {
    WebContentView(
        store: .init(
            initialState: .init(urlString: "https://naver.com", navigationTitle: "네이버"),
            reducer: {
                WebContentFeature()
            }
        )
    )
}
