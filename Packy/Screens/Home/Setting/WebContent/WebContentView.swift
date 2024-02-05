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
    @ObservedObject private var viewStore: ViewStoreOf<WebContentFeature>

    init(store: StoreOf<WebContentFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        VStack {
            NavigationBar(
                title: viewStore.navigationTitle,
                leftIcon: Image(.arrowLeft)) {
                    viewStore.send(.backButtonTapped)
                }
            WebView(urlString: viewStore.urlString)
        }
        .task {
            await viewStore
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
