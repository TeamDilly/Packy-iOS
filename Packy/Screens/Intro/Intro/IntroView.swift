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
    @ObservedObject private var viewStore: ViewStoreOf<IntroFeature>

    init(store: StoreOf<IntroFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        SwitchStore(store) { state in
            switch state {
            case .onboarding:
                CaseLet(\IntroFeature.State.onboarding, action: IntroFeature.Action.onboarding) { store in
                    OnboardingView(store: store)
                }

            case .login:
                CaseLet(\IntroFeature.State.login, action: IntroFeature.Action.login) { store in
                    LoginView(store: store)
                }

            case .termsAgreement:
                CaseLet(\IntroFeature.State.termsAgreement, action: IntroFeature.Action.termsAgreement) { store in
                    TermsAgreementView(store: store)
                }
            }
        }
        .task {
            await viewStore
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
