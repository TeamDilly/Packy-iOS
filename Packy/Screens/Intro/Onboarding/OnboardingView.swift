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
        VStack(spacing: 0) {
            Spacer()

            TabView(selection: viewStore.$currentPage) {
                ForEach(OnboardingPage.allCases, id: \.self) {
                    pageView($0)
                }
            }
            .tabViewStyle(.page)

            Spacer()

            PackyButton(title: viewStore.currentPage.buttonTitle) {
                viewStore.send(.bottomButtonTapped)
            }
        }
        .animation(.spring, value: viewStore.currentPage)
        .transition(.slide)
        .task {
            await viewStore
                .send(._onAppear)
                .finish()
        }
    }
}

// MARK: - Inner Views

private extension OnboardingView {
    func pageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: 0) {
            Text(page.title)
                .multilineTextAlignment(.center)
                .packyFont(.heading1)
                .padding(.horizontal)
                .padding(.bottom, 44)

            page.image
                .resizable()
                .frame(width: 300, height: 300)

            PageIndicator(
                totalPages: OnboardingPage.allCases.count,
                currentPage: page.rawValue
            )
            .padding(.top, 24)
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
