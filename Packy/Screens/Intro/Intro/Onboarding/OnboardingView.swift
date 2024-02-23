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
    @Bindable private var store: StoreOf<OnboardingFeature>

    init(store: StoreOf<OnboardingFeature>) {
        self.store = store
    }

    var body: some View {
        GeometryReader { geometry in
            let yOffsetRatio: CGFloat = UIScreen.main.isWiderThan375pt ? 0.13 : 0.08
            let yOffset = -geometry.size.height * yOffsetRatio

            VStack(spacing: 0) {
                Button("건너뛰기") {
                    store.send(.skipButtonTapped)
                }
                .buttonStyle(TextButtonStyle(colorType: .gray))
                .frame(width: 65, height: 48)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 16)

                Spacer()

                TabView(selection: $store.currentPage) {
                    ForEach(OnboardingPage.allCases, id: \.self) {
                        pageView($0)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .overlay(alignment: .center) {

                }

                PageIndicator(
                    totalPages: OnboardingPage.allCases.count,
                    currentPage: store.currentPage.rawValue
                )
                .offset(y: yOffset)

                Spacer()

                PackyButton(title: store.currentPage.buttonTitle) {
                    store.send(.bottomButtonTapped)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }

        }
        .animation(.spring, value: store.currentPage)
        .task {
            await store
                .send(._onAppear)
                .finish()
        }
    }
}

// MARK: - Inner Views

private extension OnboardingView {
    func pageView(_ page: OnboardingPage) -> some View {
        page.image
            .overlay(alignment: .top) {
                Text(page.title)
                    .multilineTextAlignment(.center)
                    .packyFont(.heading1)
                    .padding(.horizontal)
                    .offset(y: -16)
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
