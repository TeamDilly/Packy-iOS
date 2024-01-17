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
        @BindingState var currentPage: OnboardingPage = .makeBox
    }

    enum Action: BindableAction {
        // MARK: User Action
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
            case .bottomButtonTapped:
                guard state.currentPage != OnboardingPage.allCases.last else {
                    return .run { send in
                        await userDefaults.setBool(true, .hasOnboarded)
                        await send(.delegate(.completeOnboarding))
                    }
                }

                state.currentPage = .rememberEvent
                return .none

            default:
                return .none
            }

        }
    }
}
