//
//  OnboardingFeature.swift
//  Packy
//
//  Created Mason Kim on 1/7/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct OnboardingFeature: Reducer {

    struct State: Equatable {
        @BindingState var currentPage: OnboardingPage = .one
    }

    enum Action: BindableAction {
        // MARK: User Action
        case skipButtonTapped
        case bottomButtonTapped
        case binding(BindingAction<State>)

        // MARK: Inner Business Action
        case _onAppear

        // MARK: Delegate Action
        case delegate(Delegate)

        enum Delegate {
            case completeOnboarding
        }
    }

    @Dependency(\.userDefaults) var userDefaults

    var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .skipButtonTapped:
                return finishOnboarding()

            case .bottomButtonTapped:
                guard state.currentPage != OnboardingPage.allCases.last else {
                    return finishOnboarding()
                }

                state.currentPage = .two
                return .none

            default:
                return .none
            }

        }
    }

    private func finishOnboarding() -> Effect<Action> {
        .run { send in
            await userDefaults.setBool(true, .hasOnboarded)
            await send(.delegate(.completeOnboarding))
        }
    }
}
