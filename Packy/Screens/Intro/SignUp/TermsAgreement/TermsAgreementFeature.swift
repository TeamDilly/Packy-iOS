//
//  TermsAgreementFeature.swift
//  Packy
//
//  Created Mason Kim on 1/7/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct TermsAgreementFeature: Reducer {

    struct State: Equatable {
        var termsStates: [Terms: Bool] = Terms.allCases.reduce(into: [Terms: Bool]()) {
            $0[$1] = false
        }
        var isAllTermsAgreed: Bool {
            termsStates.allSatisfy { $1 == true }
        }
        var isAllRequiredTermsAgreed: Bool {
            termsStates
                .filter { $0.key.isRequired }
                .allSatisfy { $1 == true }
        }

        var isATTCompleted: Bool = false

        @BindingState var isAllowNotificationBottomSheetPresented: Bool = false
    }

    enum Action: BindableAction {
        // MARK: User Action
        case binding(BindingAction<State>)
        case backButtonTapped
        case agreeTermsButtonTapped(Terms)
        case agreeAllTermsButtonTapped
        case confirmButtonTapped

        case allowNotificationButtonTapped

        // MARK: Inner Business Action
        case _onAppear
        case _completeTermsAgreement

        // MARK: Inner SetState Action
        case _setATTCompleted

        // MARK: Child Action
    }

    @Dependency(\.dismiss) var dismiss
    @Dependency(\.continuousClock) var clock
    @Dependency(\.userNotification) var userNotification

    var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case ._onAppear:
                return .run { send in
                    try await clock.sleep(for: .seconds(1))
                }

            case .backButtonTapped:
                return .run { _ in
                    await dismiss()
                }

            case .confirmButtonTapped:
                return .run { send in
                    await ATTManager.requestAuthorization()

                    // 여기서 종료되고, 네비게이팅 or 바텀시트 노출.. 등
                    await send(._setATTCompleted)
                }

            case let .agreeTermsButtonTapped(terms):
                state.termsStates[terms]?.toggle()
                return .none

            case .agreeAllTermsButtonTapped:
                let isAllTermsAgreed = state.isAllTermsAgreed
                Terms.allCases.forEach {
                    state.termsStates[$0] = !isAllTermsAgreed
                }
                return .none

            case .allowNotificationButtonTapped:
                return .run { send in
                    let isGranted = try await userNotification.requestAuthorization([.alert, .badge, .sound])
                    await send(.binding(.set(\.$isAllowNotificationBottomSheetPresented, false)))
                    await send(._completeTermsAgreement, animation: .spring)
                    print("🔔 UserNotification isGranted: \(isGranted)")
                }

            case ._setATTCompleted:
                state.isATTCompleted = true
                state.isAllowNotificationBottomSheetPresented = true
                return .none

            default:
                return .none
            }
        }
    }
}
