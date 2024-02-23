//
//  IntroView.swift
//  Packy
//
//  Created Mason Kim on 1/7/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct IntroView: View {
    private let store: StoreOf<IntroFeature>

    init(store: StoreOf<IntroFeature>) {
        self.store = store
    }

    var body: some View {
        Group {
            switch store.state {
            case .splash:
                if let store = store.scope(state: \.splash, action: \.splash) {
                    SplashView(store: store)
                }

            case .onboarding:
                if let store = store.scope(state: \.onboarding, action: \.onboarding) {
                    OnboardingView(store: store)
                }

            case .login:
                if let store = store.scope(state: \.login, action: \.login) {
                    LoginView(store: store)
                }

            case .signUp:
                if let store = store.scope(state: \.signUp, action: \.signUp) {
                    SignUpNicknameView(store: store)
                }
            }
        }
        .task {
            await store
                .send(._onAppear)
                .finish()
        }
    }
}

// MARK: - Preview

#Preview {
    IntroView(
        store: .init(
            initialState: .init(),
            reducer: {
                IntroFeature()
                    ._printChanges()
            }
        )
    )
}
