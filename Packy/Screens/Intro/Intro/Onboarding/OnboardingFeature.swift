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

    @ObservableState
    struct State: Equatable {
        var currentPage: OnboardingPage = .one
    }

    enum Action: ViewAction {
        case view(View)
        case delegate(Delegate)

        enum View: BindableAction {
            case onTask
            case skipButtonTapped
            case bottomButtonTapped
            case binding(BindingAction<State>)
        }

        enum Delegate {
            case completeOnboarding
        }
    }

    @Dependency(\.userDefaults) var userDefaults

    var body: some Reducer<State, Action> {
        BindingReducer(action: \.view)

        Reduce<State, Action> { state, action in
            switch action {
            case let .view(action):
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
