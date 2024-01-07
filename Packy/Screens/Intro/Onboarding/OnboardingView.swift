//
//  OnboardingView.swift
//  Packy
//
//  Created Mason Kim on 1/7/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct OnboardingView: View {
    private let store: StoreOf<OnboardingFeature>
    @ObservedObject private var viewStore: ViewStoreOf<OnboardingFeature>

    init(store: StoreOf<OnboardingFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        List {
            Text("Hello, Onboarding!")
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
    OnboardingView(
        store: .init(
            initialState: .init(),
            reducer: {
                OnboardingFeature()
                    ._printChanges()
            }
        )
    )
}
